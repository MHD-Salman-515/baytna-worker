import 'package:baytna_worker/core/config/app_config.dart';
import 'package:baytna_worker/core/network/auth_interceptor.dart';
import 'package:baytna_worker/core/network/debug_log_interceptor.dart';
import 'package:baytna_worker/core/network/envelope_interceptor.dart';
import 'package:baytna_worker/core/network/refresh_interceptor.dart';
import 'package:baytna_worker/core/network/server_status.dart';
import 'package:baytna_worker/core/network/token_refresher.dart';
import 'package:baytna_worker/core/network/wake_up_interceptor.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Builds the two Dio instances. Kept outside the DI module so tests can
/// assemble the exact production pipeline around a fake HTTP adapter.
abstract final class DioFactory {
  /// Bare client for POST /auth/refresh: envelope + cold-start handling only.
  static Dio createRefreshDio(AppConfig config, ServerStatus status) {
    final dio = Dio(_options(config));
    dio.interceptors.addAll([
      WakeUpInterceptor(dio: dio, status: status, threshold: config.slowRequestThreshold),
      if (kDebugMode) DebugLogInterceptor(),
      EnvelopeInterceptor(),
    ]);
    return dio;
  }

  /// The client every feature uses (through ApiClient). Order matters:
  /// wake-up tracking wraps everything; the envelope is unwrapped before
  /// auth/refresh logic looks at responses.
  static Dio createApiDio({
    required AppConfig config,
    required ServerStatus status,
    required TokenStorage storage,
    required TokenRefresher refresher,
    Iterable<Interceptor> extra = const [],
  }) {
    final dio = Dio(_options(config));
    dio.interceptors.addAll([
      WakeUpInterceptor(dio: dio, status: status, threshold: config.slowRequestThreshold),
      ...extra,
      AuthInterceptor(storage, refresher),
      if (kDebugMode) DebugLogInterceptor(),
      EnvelopeInterceptor(),
      RefreshInterceptor(dio: dio, storage: storage, refresher: refresher),
    ]);
    return dio;
  }

  static BaseOptions _options(AppConfig config) => BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: config.connectTimeout,
    receiveTimeout: config.receiveTimeout,
    sendTimeout: kIsWeb ? null : config.sendTimeout,
    contentType: Headers.jsonContentType,
  );
}
