import 'dart:async';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements WorkerRepository;

class _MockAuth extends Mock implements AuthBloc;

const _user = User(id: 'u1', phone: '+963911111111', countryId: 'c1', roles: ['CUSTOMER', 'WORKER']);
const _profile = WorkerProfile(
  id: 'w1',
  countryId: 'c1',
  verificationStatus: VerificationStatus.pendingReview,
  financialStatus: FinancialStatus.active,
);

void main() {
  late _MockRepo repo;
  late _MockAuth auth;
  late StreamController<AuthState> authStates;

  setUp(() {
    repo = _MockRepo();
    auth = _MockAuth();
    authStates = StreamController<AuthState>.broadcast();
    when(() => auth.state).thenReturn(const AuthUnknown());
    when(() => auth.stream).thenAnswer((_) => authStates.stream);
  });

  tearDown(() => authStates.close());

  Future<List<WorkerState>> run(WorkerBloc bloc, Future<void> Function() act) async {
    final seen = <WorkerState>[];
    final sub = bloc.stream.listen(seen.add);
    await act();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub.cancel();
    return seen;
  }

  test('signing in loads the profile with the account roles', () async {
    when(() => repo.fetchProfile(accountRoles: any(named: 'accountRoles'))).thenAnswer((_) async => const Ok(_profile));
    final bloc = WorkerBloc(repo, auth);
    final states = await run(bloc, () async => authStates.add(const AuthAuthenticated(_user)));
    expect(states.last, const WorkerLoaded(_profile));
    verify(() => repo.fetchProfile(accountRoles: ['CUSTOMER', 'WORKER'])).called(1);
    await bloc.close();
  });

  test('never applied → WorkerNotApplied; load failure → WorkerLoadFailed (not approved)', () async {
    when(() => repo.fetchProfile(accountRoles: any(named: 'accountRoles'))).thenAnswer((_) async => const Ok(null));
    final bloc = WorkerBloc(repo, auth);
    expect((await run(bloc, () async => authStates.add(const AuthAuthenticated(_user)))).last, const WorkerNotApplied());

    when(() => repo.fetchProfile(accountRoles: any(named: 'accountRoles'))).thenAnswer((_) async => const Err(NetworkFailure()));
    expect((await run(bloc, () async => bloc.add(const WorkerLoadRequested()))).last, const WorkerLoadFailed(NetworkFailure()));
    await bloc.close();
  });

  test('a failed background refresh keeps the loaded profile', () async {
    when(() => repo.fetchProfile(accountRoles: any(named: 'accountRoles'))).thenAnswer((_) async => const Ok(_profile));
    final bloc = WorkerBloc(repo, auth);
    await run(bloc, () async => authStates.add(const AuthAuthenticated(_user)));
    when(() => repo.fetchProfile(accountRoles: any(named: 'accountRoles'))).thenAnswer((_) async => const Err(TimeoutFailure()));
    await run(bloc, () async => bloc.add(const WorkerRefreshRequested()));
    expect(bloc.state, const WorkerLoaded(_profile));
    await bloc.close();
  });

  test('signing out forgets the profile', () async {
    when(() => repo.fetchProfile(accountRoles: any(named: 'accountRoles'))).thenAnswer((_) async => const Ok(_profile));
    final bloc = WorkerBloc(repo, auth);
    await run(bloc, () async => authStates.add(const AuthAuthenticated(_user)));
    await run(bloc, () async => authStates.add(const AuthUnauthenticated()));
    expect(bloc.state, const WorkerUnknown());
    await bloc.close();
  });
}
