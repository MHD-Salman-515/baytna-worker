import 'package:dio/dio.dart';

/// Sends the current app language so server-side messages and push content
/// can be localized.
class AcceptLanguageInterceptor extends Interceptor {
  AcceptLanguageInterceptor(this._languageCode);

  final String Function() _languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _languageCode();
    handler.next(options);
  }
}
