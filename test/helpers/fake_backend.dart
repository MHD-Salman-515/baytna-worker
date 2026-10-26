import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef Handler =
    Future<(int, Object?)> Function(RequestOptions options, Object? body);

/// An HttpClientAdapter that routes by "METHOD /path" and records traffic.
/// Bodies are wrapped in the backend's envelope automatically.
class FakeBackend implements HttpClientAdapter {
  FakeBackend(this.routes);

  final Map<String, Handler> routes;
  final List<RequestOptions> requests = [];

  /// Authorization header of each request AS SENT (RequestOptions objects are
  /// reused and mutated on replay, so they can't be inspected afterwards).
  final List<String?> sentAuth = [];

  int count(String route) =>
      requests.where((r) => '${r.method} ${r.uri.path}' == route).length;

  static (int, Object?) ok(Object? data) => (200, {'success': true, 'data': data});

  static (int, Object?) error(int status, Object message) => (
    status,
    {
      'success': false,
      'error': {'statusCode': status, 'message': message, 'error': 'Error'},
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    sentAuth.add(options.headers['Authorization'] as String?);
    final key = '${options.method} ${options.uri.path}';
    final handler = routes[key];
    final (status, body) = handler == null
        ? error(404, 'Cannot $key')
        : await handler(options, options.data);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
