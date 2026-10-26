import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/token_refresher.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/jwt.dart';
import 'package:dio/dio.dart';

/// Attaches `Authorization: Bearer <access token>`.
///
///  * Requests created while a refresh is running are QUEUED here until it
///    settles, then sent with the new token (no doomed request with the old one).
///  * If the stored access token is already (nearly) expired, it triggers a
///    refresh up front rather than collecting a guaranteed 401.
///
/// Public endpoints opt out with `extra: {AuthInterceptor.skipAuth: true}`
/// (ApiClient does this for `authenticated: false`).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._refresher);

  final TokenStorage _storage;
  final TokenRefresher _refresher;

  static const skipAuth = 'auth.skip';

  /// The token a request was actually sent with; RefreshInterceptor compares
  /// it to the current one to avoid refreshing twice for the same expiry.
  static const tokenUsed = 'auth.tokenUsed';

  static const _expiryLeeway = Duration(seconds: 30);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuth] == true) return handler.next(options);

    try {
      await _refresher.waitForPendingRefresh();
      var tokens = await _storage.read();
      if (tokens == null) return handler.next(options);

      if (Jwt.isExpired(tokens.accessToken, leeway: _expiryLeeway)) {
        tokens = await _refresher.refresh();
      }

      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      options.extra[tokenUsed] = tokens.accessToken;
      handler.next(options);
    } on Failure catch (failure) {
      handler.reject(DioException(requestOptions: options, error: failure));
    }
  }
}
