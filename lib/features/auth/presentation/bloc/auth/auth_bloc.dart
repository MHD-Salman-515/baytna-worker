import 'dart:async';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/locale_cubit.dart';
import 'package:baytna_worker/core/network/session_events.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/entities/auth_session.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Owns the session for the whole app. The router redirects on its state.
///
/// Inputs: app start, a successful OTP verification, a logout tap, the
/// network layer reporting an unrecoverable refresh failure, and language
/// changes (synced to the server while signed in).
@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._locale, SessionEvents sessionEvents)
    : super(const AuthUnknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthLocaleChanged>(_onLocaleChanged);
    _expirySub = sessionEvents.onExpired.listen((_) => add(const AuthSessionExpired()));
  }

  final AuthRepository _repository;
  final LocaleCubit _locale;
  late final StreamSubscription<void> _expirySub;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    if (!await _repository.hasStoredSession()) {
      return emit(const AuthUnauthenticated());
    }
    switch (await _repository.fetchCurrentUser()) {
      case Ok(value: final user):
        emit(AuthAuthenticated(user));
      case Err(failure: SessionExpiredFailure() || UnauthorizedFailure()):
        await _repository.clearLocalSession();
        emit(const AuthUnauthenticated(sessionExpired: true));
      case Err():
        // Offline or the server is still asleep: the tokens are fine as far
        // as we know, so start with the cached user rather than logging out.
        final cached = await _repository.cachedUser();
        if (cached != null) {
          emit(AuthAuthenticated(cached));
        } else {
          await _repository.clearLocalSession();
          emit(const AuthUnauthenticated());
        }
    }
  }

  Future<void> _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthAuthenticated(event.session.user));
    await _syncLocale(_locale.state.languageCode);
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) async {
    // During AuthStarted the startup handler deals with it; after a logout
    // there is nothing to do.
    if (state is! AuthAuthenticated) return;
    await _repository.clearLocalSession();
    emit(const AuthUnauthenticated(sessionExpired: true));
  }

  Future<void> _onLocaleChanged(AuthLocaleChanged event, Emitter<AuthState> emit) async {
    if (state is AuthAuthenticated) await _syncLocale(event.languageCode);
  }

  /// Best effort: a failed sync must never disturb the session.
  Future<void> _syncLocale(String code) async {
    final result = await _repository.updateLocale(code);
    if (result case Err(:final failure)) debugPrint('Locale sync failed: $failure');
  }

  @override
  Future<void> close() async {
    await _expirySub.cancel();
    await super.close();
  }
}
