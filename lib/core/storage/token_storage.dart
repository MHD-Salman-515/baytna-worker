import 'package:baytna_worker/core/network/json.dart';
import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  /// Shape shared by POST /auth/otp/verify and POST /auth/refresh.
  factory AuthTokens.fromJson(Json json) => AuthTokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );

  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];

  /// Never print tokens.
  @override
  String toString() => 'AuthTokens(<redacted>)';
}

/// Persistent token store. The production implementation is backed by
/// flutter_secure_storage — tokens must never go into SharedPreferences.
abstract interface class TokenStorage {
  Future<AuthTokens?> read();
  Future<void> save(AuthTokens tokens);
  Future<void> clear();
}
