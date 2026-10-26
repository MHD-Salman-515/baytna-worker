part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once at launch: decide from stored tokens where to go.
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// OTP verified; tokens are already persisted by the repository.
final class AuthLoggedIn extends AuthEvent {
  const AuthLoggedIn(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// From [SessionEvents]: the refresh token was rejected.
final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

final class AuthLocaleChanged extends AuthEvent {
  const AuthLocaleChanged(this.languageCode);

  final String languageCode;

  @override
  List<Object?> get props => [languageCode];
}
