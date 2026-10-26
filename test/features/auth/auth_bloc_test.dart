import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/locale_cubit.dart';
import 'package:baytna_worker/core/network/session_events.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/entities/auth_session.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/auth/domain/repositories/auth_repository.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements AuthRepository;

class _MockLocale extends Mock implements LocaleCubit;

void main() {
  const user = User(id: 'u1', phone: '+963911111111', countryId: 'c1');
  late _MockRepo repo;
  late _MockLocale locale;
  late SessionEvents events;

  setUp(() {
    repo = _MockRepo();
    locale = _MockLocale();
    events = SessionEvents();
    when(() => locale.state).thenReturn(const Locale('ar'));
    when(() => repo.clearLocalSession()).thenAnswer((_) async {});
    when(() => repo.updateLocale(any())).thenAnswer((_) async => const Ok(null));
  });

  AuthBloc build() => AuthBloc(repo, locale, events);

  blocTest<AuthBloc, AuthState>(
    'no stored tokens → unauthenticated',
    setUp: () => when(() => repo.hasStoredSession()).thenAnswer((_) async => false),
    build: build,
    act: (b) => b.add(const AuthStarted()),
    expect: () => [const AuthUnauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'stored tokens + /auth/me OK → authenticated',
    setUp: () {
      when(() => repo.hasStoredSession()).thenAnswer((_) async => true);
      when(() => repo.fetchCurrentUser()).thenAnswer((_) async => const Ok(user));
    },
    build: build,
    act: (b) => b.add(const AuthStarted()),
    expect: () => [const AuthAuthenticated(user)],
  );

  blocTest<AuthBloc, AuthState>(
    'stored tokens but refresh rejected → unauthenticated(sessionExpired)',
    setUp: () {
      when(() => repo.hasStoredSession()).thenAnswer((_) async => true);
      when(() => repo.fetchCurrentUser()).thenAnswer((_) async => const Err(SessionExpiredFailure()));
    },
    build: build,
    act: (b) => b.add(const AuthStarted()),
    expect: () => [const AuthUnauthenticated(sessionExpired: true)],
  );

  blocTest<AuthBloc, AuthState>(
    'server asleep/offline at startup → authenticated with cached user',
    setUp: () {
      when(() => repo.hasStoredSession()).thenAnswer((_) async => true);
      when(() => repo.fetchCurrentUser()).thenAnswer((_) async => const Err(TimeoutFailure()));
      when(() => repo.cachedUser()).thenAnswer((_) async => user);
    },
    build: build,
    act: (b) => b.add(const AuthStarted()),
    expect: () => [const AuthAuthenticated(user)],
    verify: (_) => verifyNever(() => repo.clearLocalSession()),
  );

  blocTest<AuthBloc, AuthState>(
    'login → authenticated, then PATCHes the current locale',
    build: build,
    act: (b) => b.add(const AuthLoggedIn(AuthSession(user: user, isNewUser: false))),
    expect: () => [const AuthAuthenticated(user)],
    verify: (_) => verify(() => repo.updateLocale('ar')).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'refresh failure while signed in → unauthenticated(sessionExpired)',
    build: build,
    seed: () => const AuthAuthenticated(user),
    act: (_) => events.notifyExpired(),
    expect: () => [const AuthUnauthenticated(sessionExpired: true)],
  );

  blocTest<AuthBloc, AuthState>(
    'logout → unauthenticated',
    setUp: () => when(() => repo.logout()).thenAnswer((_) async {}),
    build: build,
    seed: () => const AuthAuthenticated(user),
    act: (b) => b.add(const AuthLogoutRequested()),
    expect: () => [const AuthUnauthenticated()],
  );
}
