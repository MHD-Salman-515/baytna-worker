import 'package:dio/dio.dart';

/// The one place that knows about the backend's response envelope:
///
///   success: `{ "success": true,  "data": ... }`
///   failure: `{ "success": false, "error": { statusCode, message, error } }`
///
/// On success `response.data` is replaced by the inner `data`, so everything
/// downstream (ApiClient, data sources) sees the bare payload. Failures are
/// parsed by [ApiError.tryParse] inside `ErrorMapper`.
///
/// Paginated endpoints (e.g. GET /cities) send `meta` NEXT TO `data`:
/// `{ success, data: [...], meta: { page, limit, total, totalPages } }`.
/// It is kept in `response.extra[metaKey]` so `ApiClient.getPage` can read it.
class EnvelopeInterceptor extends Interceptor {
  static const metaKey = 'envelope.meta';

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['success'] is bool) {
      if (body['success'] == true) {
        response.data = body['data'];
        if (body['meta'] != null) response.extra[metaKey] = body['meta'];
        return handler.next(response);
      }
      // A 2xx carrying success:false — treat it like the error it describes.
      return handler.reject(
        DioException.badResponse(
          statusCode: ApiError.tryParse(body)?.statusCode ?? 500,
          requestOptions: response.requestOptions,
          response: response,
        ),
        true,
      );
    }
    // 204 No Content or a non-enveloped body: pass through untouched.
    handler.next(response);
  }
}

/// The `error` object of a failure envelope.
class ApiError {
  const ApiError({required this.statusCode, required this.messages, this.error});

  final int? statusCode;

  /// `message` is a string for most errors but a list of strings for
  /// class-validator 400s; both are normalized to a list.
  final List<String> messages;
  final String? error;

  String get message => messages.join('; ');

  static ApiError? tryParse(Object? body) {
    if (body is! Map || body['success'] != false) return null;
    final error = body['error'];
    if (error is! Map) return null;
    final raw = error['message'];
    final messages = switch (raw) {
      final String s => [s],
      final List<dynamic> l => l.map((e) => e.toString()).toList(),
      _ => const <String>[],
    };
    final status = error['statusCode'];
    return ApiError(
      statusCode: status is num ? status.toInt() : null,
      messages: messages,
      error: error['error']?.toString(),
    );
  }
}
