import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/auth/data/models/user_model.dart';
import 'package:baytna_worker/features/auth/data/models/verify_otp_response.dart';
import 'package:injectable/injectable.dart';

/// Thin, 1:1 mapping of auth endpoints. Throws `Failure`s (via ApiClient);
/// the repository converts them to `Result`s.
@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiClient _api;

  Future<void> requestOtp({required String countryId, required String phone}) =>
      _api.post(
        '/auth/otp/request',
        body: {'countryId': countryId, 'phone': phone},
        decode: ApiClient.ignore,
        authenticated: false,
      );

  Future<VerifyOtpResponse> verifyOtp({
    required String countryId,
    required String phone,
    required String code,
  }) => _api.post(
    '/auth/otp/verify',
    body: {'countryId': countryId, 'phone': phone, 'code': code},
    decode: (data) => VerifyOtpResponse.fromJson(asJson(data)),
    authenticated: false,
  );

  Future<UserModel> me() =>
      _api.get('/auth/me', decode: (data) => UserModel.fromJson(asJson(data)));

  Future<void> updateLocale(String locale) => _api.patch(
    '/users/me/locale',
    body: {'locale': locale},
    decode: ApiClient.ignore,
  );

  /// Public endpoint: it authenticates by the refresh token in the body, and
  /// must not trigger a token refresh just to log out.
  Future<void> logout(String refreshToken) => _api.post(
    '/auth/logout',
    body: {'refreshToken': refreshToken},
    decode: ApiClient.ignore,
    authenticated: false,
  );
}
