/// Mirrors the backend's OTP rules. POST /auth/otp/request returns only a
/// message (no cooldown/expiry fields), so these are pinned to observed
/// server behaviour: a second request inside the window gets a 429.
abstract final class OtpPolicy {
  static const int codeLength = 6;
  static const Duration resendCooldown = Duration(seconds: 60);
}
