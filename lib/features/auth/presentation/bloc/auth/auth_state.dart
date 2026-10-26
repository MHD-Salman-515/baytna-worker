part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Before AuthStarted has finished — the splash screen is shown.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.sessionExpired = false});

  /// True when the server ended the session (vs. a deliberate logout), so the
  /// UI can explain why the user is back at the login screen.
  final bool sessionExpired;

  @override
  List<Object?> get props => [sessionExpired];
}
