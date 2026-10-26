import 'dart:async';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/core/utils/ticker.dart';
import 'package:baytna_worker/features/auth/domain/auth_failures.dart';
import 'package:baytna_worker/features/auth/domain/entities/auth_session.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/auth/domain/repositories/auth_repository.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/otp/otp_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements AuthRepository;

/// Countdown driven manually by the test.
class _ManualTicker implements Ticker {
  final controller = StreamController<int>.broadcast();

  @override
  Stream<int> countdown(int from) => controller.stream;
}

void main() {
  const phone = '+963911111111';
  const session = AuthSession(user: User(id: 'u1', phone: phone, countryId: 'c1'), isNewUser: false);
  late _MockRepo repo;
  late _ManualTicker ticker;

  setUp(() {
    repo = _MockRepo();
    ticker = _ManualTicker();
  });

  OtpBloc build() => OtpBloc(repo, ticker, 'c1', phone);

  void verifyReturns(Result<AuthSession> r) => when(
    () => repo.verifyOtp(
      countryId: any(named: 'countryId'),
      phone: any(named: 'phone'),
      code: any(named: 'code'),
    ),
  ).thenAnswer((_) async => r);

  test('starts with the 60-second cooldown', () {
    expect(build().state.resendIn, 60);
  });

  blocTest<OtpBloc, OtpState>(
    'six digits auto-submit (Arabic-Indic digits accepted) → verified',
    setUp: () => verifyReturns(const Ok(session)),
    build: build,
    act: (b) => b.add(const OtpCodeChanged('١٢٣٤٥٦')),
    skip: 1,
    expect: () => [
      const OtpState(resendIn: 60, code: '123456', status: OtpVerifying()),
      const OtpState(resendIn: 60, code: '123456', status: OtpVerified(session)),
    ],
  );

  blocTest<OtpBloc, OtpState>(
    'wrong code → OtpInvalidCode, code cleared, input stays enabled',
    setUp: () => verifyReturns(const Err(InvalidOtpCode())),
    build: build,
    act: (b) => b.add(const OtpCodeChanged('000000')),
    verify: (b) {
      expect(b.state.status, const OtpInvalidCode());
      expect(b.state.code, '');
    },
  );

  blocTest<OtpBloc, OtpState>(
    'too many attempts → locked: typing is ignored and submit is impossible',
    setUp: () => verifyReturns(const Err(TooManyOtpAttempts())),
    build: build,
    act: (b) async {
      b.add(const OtpCodeChanged('000000'));
      await Future<void>.delayed(Duration.zero);
      b.add(const OtpCodeChanged('12'));
    },
    verify: (b) {
      expect(b.state.status, const OtpTooManyAttempts());
      expect(b.state.code, '');
      expect(b.state.canSubmit, isFalse);
    },
  );

  blocTest<OtpBloc, OtpState>(
    'resend is blocked during the countdown and allowed at 0',
    setUp: () => when(
      () => repo.requestOtp(countryId: any(named: 'countryId'), phone: any(named: 'phone')),
    ).thenAnswer((_) async => const Ok(null)),
    build: build,
    act: (b) async {
      b
        ..add(const OtpStarted())
        ..add(const OtpResendRequested()); // ignored: 60s left
      await Future<void>.delayed(Duration.zero);
      ticker.controller.add(0);
      await Future<void>.delayed(Duration.zero);
      b.add(const OtpResendRequested());
    },
    verify: (b) {
      verify(() => repo.requestOtp(countryId: 'c1', phone: phone)).called(1);
      expect(b.state.status, const OtpResent());
      expect(b.state.resendIn, 60); // cooldown restarted
    },
  );

  blocTest<OtpBloc, OtpState>(
    'resend inside the server cooldown (429) → OtpFailed(RateLimited)',
    setUp: () => when(
      () => repo.requestOtp(countryId: any(named: 'countryId'), phone: any(named: 'phone')),
    ).thenAnswer((_) async => const Err(RateLimitedFailure())),
    build: build,
    seed: () => const OtpState(resendIn: 0),
    act: (b) => b.add(const OtpResendRequested()),
    verify: (b) {
      expect(b.state.status, const OtpFailed(RateLimitedFailure()));
      expect(b.state.resendIn, 60);
    },
  );
}
