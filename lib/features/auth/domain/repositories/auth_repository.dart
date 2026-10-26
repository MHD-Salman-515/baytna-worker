import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/entities/auth_session.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  /// [phone] must already be E.164. Fails with `InvalidPhoneNumber` or
  /// `RateLimitedFailure` (60-second cooldown) among the generic failures.
  Future<Result<void>> requestOtp({required String countryId, required String phone});

  /// Persists tokens and the user on success. Fails with `InvalidOtpCode` or
  /// `TooManyOtpAttempts` among the generic failures.
  Future<Result<AuthSession>> verifyOtp({
    required String countryId,
    required String phone,
    required String code,
  });

  /// Whether tokens are stored (says nothing about their validity).
  Future<bool> hasStoredSession();

  /// The user cached at login, for starting offline.
  Future<User?> cachedUser();

  /// GET /auth/me — validates the session (refreshing if needed).
  Future<Result<User>> fetchCurrentUser();

  Future<Result<void>> updateLocale(String languageCode);

  /// Clears local state immediately; revokes the refresh token server-side
  /// in the background (best effort).
  Future<void> logout();

  /// Clears local state only (after the server already rejected the session).
  Future<void> clearLocalSession();
}
