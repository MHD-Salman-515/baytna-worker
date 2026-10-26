import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/auth_interceptor.dart';
import 'package:baytna_worker/core/network/replay.dart';
import 'package:baytna_worker/core/network/token_refresher.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:dio/dio.dart';

/// On a 401 for an authenticated request: refresh (single-flight, via
/// [TokenRefresher]) and replay the request once with the new token.
///
/// If the token has already changed since this request was sent — another
/// request's refresh beat us to it — we just replay with the current token
/// and do NOT refresh again. That check, plus the refresher's shared Future,
/// is what guarantees a rotated refresh token is never presented twice.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required this._dio,
    required this._storage,
    required this._refresher,
  });

  final Dio _dio;
  final TokenStorage _storage;
  final TokenRefresher _refresher;

  static const _replayed = 'refresh.replayed';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final sentWith = options.extra[AuthInterceptor.tokenUsed] as String?;
    if (err.response?.statusCode != 401 ||
        sentWith == null ||
        options.extra[_replayed] == true) {
      return handler.next(err);
    }

    try {
      final current = await _storage.read();
      if (current == null || current.accessToken == sentWith) {
        await _refresher.refresh();
      }
      // AuthInterceptor re-attaches the (now current) token on replay.
      options.extra[_replayed] = true;
      replayableBody(options);
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on Failure catch (failure) {
      handler.reject(DioException(requestOptions: options, error: failure));
    } on DioException catch (e) {
      handler.reject(e);
    }
  }
}
