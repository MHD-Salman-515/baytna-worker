part of 'otp_bloc.dart';

sealed class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

/// The screen opened right after a code was sent: start the cooldown.
final class OtpStarted extends OtpEvent {
  const OtpStarted();
}

/// Typing (or the dev helper autofilling). Six digits auto-submit.
final class OtpCodeChanged extends OtpEvent {
  const OtpCodeChanged(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class OtpSubmitted extends OtpEvent {
  const OtpSubmitted();
}

final class OtpResendRequested extends OtpEvent {
  const OtpResendRequested();
}

final class _OtpTicked extends OtpEvent {
  const _OtpTicked(this.secondsLeft);

  final int secondsLeft;

  @override
  List<Object?> get props => [secondsLeft];
}
