import 'dart:convert';

import 'package:baytna_worker/core/config/app_config.dart';
import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/dio_factory.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/core/network/server_status.dart';
import 'package:baytna_worker/core/network/session_events.dart';
import 'package:baytna_worker/core/network/token_refresher.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';

import 'fake_backend.dart';
import 'in_memory_token_storage.dart';

const testConfig = AppConfig(
  environment: AppEnvironment.staging,
  apiBaseUrl: 'https://api.test/api/v1',
  slowRequestThreshold: Duration(milliseconds: 50),
);

/// An unsigned JWT with the claims the app reads (`exp`, `roles`).
String testJwt({DateTime? exp, List<String> roles = const ['CUSTOMER'], String tag = ''}) {
  String part(Map<String, Object> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final expiry = exp ?? DateTime.now().add(const Duration(minutes: 15));
  return '${part({'alg': 'HS256'})}.'
      '${part({'exp': expiry.millisecondsSinceEpoch ~/ 1000, 'roles': roles, 'tag': tag})}.sig';
}

/// The PRODUCTION interceptor pipeline (DioFactory) around a [FakeBackend].
class ApiHarness {
  ApiHarness(Map<String, Handler> routes, {AuthTokens? tokens})
    : backend = FakeBackend(routes),
      storage = InMemoryTokenStorage(tokens) {
    final refreshDio = DioFactory.createRefreshDio(testConfig, status)..httpClientAdapter = backend;
    refresher = TokenRefresher(storage, refreshDio, events);
    final dio = DioFactory.createApiDio(
      config: testConfig,
      status: status,
      storage: storage,
      refresher: refresher,
    )..httpClientAdapter = backend;
    api = ApiClient(dio);
    events.onExpired.listen((_) => expiredCount++);
  }

  final FakeBackend backend;
  final InMemoryTokenStorage storage;
  final ServerStatus status = ServerStatus();
  final SessionEvents events = SessionEvents();
  late final TokenRefresher refresher;
  late final ApiClient api;
  int expiredCount = 0;

  Future<Json> me() => api.get('/auth/me', decode: asJson);
}
