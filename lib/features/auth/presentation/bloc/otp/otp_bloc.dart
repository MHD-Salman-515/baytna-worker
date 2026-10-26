import 'dart:async';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/core/utils/ticker.dart';
import 'package:baytna_worker/features/auth/domain/auth_failures.dart';
import 'package:baytna_worker/features/auth/domain/entities/auth_session.dart';
import 'package:baytna_worker/features/auth/domain/otp_policy.dart';
import 'package:baytna_worker/features/auth/domain/phone_number.dart';
import 'package:baytna_worker/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'otp_event.dart';
part 'otp_state.dart';

/// OTP entry for one phone number: verify, resend with the 60-second
/// cooldown, and distinct states for wrong code / burned code / failures.
@injectable
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc(
    this._auth,
    this._ticker,
    @factoryParam this.countryId,
    @factoryParam this.phone,
  ) : super(OtpState(resendIn: OtpPolicy.resendCooldown.inSeconds)) {
    on<OtpStarted>(_onStarted);
    on<OtpCodeChanged>(_onCodeChanged);
    on<OtpSubmitted>(_onSubmitted);
    on<OtpResendRequested>(_onResendRequested);
    on<_OtpTicked>((e, emit) => emit(state.copyWith(resendIn: e.secondsLeft)));
  }

  final AuthRepository _auth;
  final Ticker _ticker;
  final String countryId;

  /// E.164 — the phone screen normalized it before sending the first code.
  final String phone;

  StreamSubscription<int>? _countdown;

  void _onStarted(OtpStarted event, Emitter<OtpState> emit) => _restartCountdown();

  void _onCodeChanged(OtpCodeChanged event, Emitter<OtpState> emit) {
    if (state.status case OtpVerifying() || OtpTooManyAttempts() || OtpVerified()) return;
    final digits = PhoneNumber.asciiDigits(event.code).replaceAll(RegExp(r'\D'), '');
    final code = digits.length > OtpPolicy.codeLength
        ? digits.substring(0, OtpPolicy.codeLength)
        : digits;
    emit(state.copyWith(code: code, status: const OtpEditing()));
    if (code.length == OtpPolicy.codeLength) add(const OtpSubmitted());
  }

  Future<void> _onSubmitted(OtpSubmitted event, Emitter<OtpState> emit) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: const OtpVerifying()));
    final result = await _auth.verifyOtp(countryId: countryId, phone: phone, code: state.code);
    emit(switch (result) {
      Ok(:final value) => state.copyWith(status: OtpVerified(value)),
      Err(failure: InvalidOtpCode()) => state.copyWith(code: '', status: const OtpInvalidCode()),
      Err(failure: TooManyOtpAttempts()) => state.copyWith(code: '', status: const OtpTooManyAttempts()),
      Err(:final failure) => state.copyWith(status: OtpFailed(failure)),
    });
  }

  Future<void> _onResendRequested(OtpResendRequested event, Emitter<OtpState> emit) async {
    if (!state.canResend) return;
    emit(state.copyWith(status: const OtpResending()));
    final result = await _auth.requestOtp(countryId: countryId, phone: phone);
    switch (result) {
      case Ok():
        emit(state.copyWith(code: '', status: const OtpResent()));
        _restartCountdown();
      case Err(:final failure):
        // Still inside the server's cooldown (e.g. after a browser refresh
        // reset our timer): wait a full window again before allowing retry.
        if (failure is RateLimitedFailure) _restartCountdown();
        emit(state.copyWith(status: OtpFailed(failure)));
    }
  }

  void _restartCountdown() {
    final seconds = OtpPolicy.resendCooldown.inSeconds;
    add(_OtpTicked(seconds));
    unawaited(_countdown?.cancel());
    _countdown = _ticker.countdown(seconds).listen((left) => add(_OtpTicked(left)));
  }

  @override
  Future<void> close() async {
    await _countdown?.cancel();
    await super.close();
  }
}
