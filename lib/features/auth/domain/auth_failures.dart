import 'package:baytna_worker/core/error/failure.dart';

/// Auth-specific failures the repository derives from generic ones. The
/// backend returns 400 for all three, so they're distinguished by message
/// (see AuthRepositoryImpl) and the UI can react to each differently.
sealed class AuthFailure extends FeatureFailure {
  const AuthFailure([super.debugMessage]);
}

/// 400 "Invalid or expired code" — let the user retry.
final class InvalidOtpCode extends AuthFailure {
  const InvalidOtpCode([super.debugMessage]);
}

/// 400 "Too many attempts — request a new code". The current code is burned;
/// retrying is pointless, the user must request a new one.
final class TooManyOtpAttempts extends AuthFailure {
  const TooManyOtpAttempts([super.debugMessage]);
}

/// 400 on OTP request: the number doesn't validate for the chosen country.
final class InvalidPhoneNumber extends AuthFailure {
  const InvalidPhoneNumber([super.debugMessage]);
}
