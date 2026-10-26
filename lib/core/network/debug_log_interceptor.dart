import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug builds only (see DioFactory). Logs method, path, status and timing;
/// never headers or bodies, so tokens and OTP codes stay out of the console.
class DebugLogInterceptor extends Interceptor {
  static const _startedKey = 'log.started';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedKey] = DateTime.now();
    final auth = options.headers.containsKey('Authorization') ? ' [bearer]' : '';
    debugPrint('[api] → ${options.method} ${options.uri.path}$auth');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    debugPrint('[api] ← ${response.statusCode} ${o.method} ${o.uri.path} ${_elapsed(o)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final status = err.response?.statusCode ?? err.type.name;
    debugPrint('[api] ✗ $status ${o.method} ${o.uri.path} ${_elapsed(o)}');
    handler.next(err);
  }

  String _elapsed(RequestOptions o) {
    final started = o.extra[_startedKey] as DateTime?;
    if (started == null) return '';
    return '(${DateTime.now().difference(started).inMilliseconds} ms)';
  }
}
