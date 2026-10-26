import 'dart:async';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:baytna_worker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:baytna_worker/features/auth/domain/auth_failures.dart';
import 'package:baytna_worker/features/auth/domain/entities/auth_session.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._tokens);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final TokenStorage _tokens;

  @override
  Future<Result<void>> requestOtp({required String countryId, required String phone}) async {
    final result = await guard(() => _remote.requestOtp(countryId: countryId, phone: phone));
    return switch (result) {
      Err(failure: ValidationFailure(:final debugMessage)) => Err(InvalidPhoneNumber(debugMessage)),
      _ => result,
    };
  }

  @override
  Future<Result<AuthSession>> verifyOtp({
    required String countryId,
    required String phone,
    required String code,
  }) async {
    final result = await guard(() async {
      final response = await _remote.verifyOtp(countryId: countryId, phone: phone, code: code);
      await _tokens.save(response.tokens);
      await _local.saveUser(response.user);
      return AuthSession(user: response.user.toEntity(), isNewUser: response.isNewUser);
    });
    return switch (result) {
      Err(failure: final ValidationFailure f) => Err(_otpFailure(f)),
      _ => result,
    };
  }

  /// The backend uses 400 for both a wrong code and a burned code; only the
  /// message differs ("Too many attempts — request a new code").
  static Failure _otpFailure(ValidationFailure f) {
    final message = f.messages.join(' ').toLowerCase();
    if (message.contains('too many attempts')) return TooManyOtpAttempts(f.debugMessage);
    if (message.contains('invalid or expired code')) return InvalidOtpCode(f.debugMessage);
    return f;
  }

  @override
  Future<bool> hasStoredSession() async => await _tokens.read() != null;

  @override
  Future<User?> cachedUser() async => (await _local.readUser())?.toEntity();

  @override
  Future<Result<User>> fetchCurrentUser() => guard(() async {
    final user = await _remote.me();
    await _local.saveUser(user);
    return user.toEntity();
  });

  @override
  Future<Result<void>> updateLocale(String languageCode) =>
      guard(() => _remote.updateLocale(languageCode));

  @override
  Future<void> logout() async {
    final tokens = await _tokens.read();
    await clearLocalSession();
    if (tokens != null) {
      // Don't make the user wait on a possibly-sleeping server to log out.
      unawaited(
        guard(() => _remote.logout(tokens.refreshToken)).then((r) {
          if (r case Err(:final failure)) debugPrint('Server logout failed: $failure');
        }),
      );
    }
  }

  @override
  Future<void> clearLocalSession() async {
    await _tokens.clear();
    await _local.clearUser();
  }
}
