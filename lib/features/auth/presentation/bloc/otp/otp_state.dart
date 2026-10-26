part of 'otp_bloc.dart';

final class OtpState extends Equatable {
  const OtpState({required this.resendIn, this.code = '', this.status = const OtpEditing()});

  final String code;

  /// Seconds until "resend" is allowed; 0 = allowed now.
  final int resendIn;
  final OtpStatus status;

  bool get canSubmit =>
      code.length == OtpPolicy.codeLength &&
      switch (status) {
        OtpVerifying() || OtpTooManyAttempts() || OtpVerified() || OtpResending() => false,
        OtpEditing() || OtpInvalidCode() || OtpResent() || OtpFailed() => true,
      };

  bool get canResend =>
      resendIn == 0 &&
      switch (status) {
        OtpVerifying() || OtpResending() || OtpVerified() => false,
        OtpEditing() || OtpInvalidCode() || OtpTooManyAttempts() || OtpResent() || OtpFailed() => true,
      };

  OtpState copyWith({String? code, int? resendIn, OtpStatus? status}) => OtpState(
    code: code ?? this.code,
    resendIn: resendIn ?? this.resendIn,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [code, resendIn, status];
}

sealed class OtpStatus extends Equatable {
  const OtpStatus();

  @override
  List<Object?> get props => [];
}

final class OtpEditing extends OtpStatus {
  const OtpEditing();
}

final class OtpVerifying extends OtpStatus {
  const OtpVerifying();
}

/// Wrong or expired code — the user may try again.
final class OtpInvalidCode extends OtpStatus {
  const OtpInvalidCode();
}

/// The code is burned; input is locked until a new code is requested.
final class OtpTooManyAttempts extends OtpStatus {
  const OtpTooManyAttempts();
}

final class OtpResending extends OtpStatus {
  const OtpResending();
}

final class OtpResent extends OtpStatus {
  const OtpResent();
}

/// Anything else: network, timeout, rate limit (cooldown), server error.
final class OtpFailed extends OtpStatus {
  const OtpFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class OtpVerified extends OtpStatus {
  const OtpVerified(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}
