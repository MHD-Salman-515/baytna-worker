import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/envelope_interceptor.dart';
import 'package:dio/dio.dart';

/// Converts anything thrown by Dio into a typed [Failure].
abstract final class ErrorMapper {
  static Failure map(Object error) {
    if (error is Failure) return error;
    if (error is! DioException) return UnknownFailure(error.toString());

    // Our own interceptors attach a Failure (e.g. SessionExpiredFailure).
    final inner = error.error;
    if (inner is Failure) return inner;

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => TimeoutFailure(error.message),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => NetworkFailure(error.message),
      DioExceptionType.cancel => const UnknownFailure('Request cancelled'),
      DioExceptionType.badResponse => fromResponse(
        error.response?.statusCode,
        error.response?.data,
      ),
      // On the VM, socket errors surface as `unknown` with no response.
      DioExceptionType.unknown =>
        error.response == null
            ? NetworkFailure(error.message ?? inner?.toString())
            : UnknownFailure(error.message),
    };
  }

  static Failure fromResponse(int? httpStatus, Object? body) {
    final apiError = ApiError.tryParse(body);
    final status = apiError?.statusCode ?? httpStatus;
    final message = apiError?.message;
    return switch (status) {
      400 || 422 => ValidationFailure(apiError?.messages ?? const []),
      401 || 403 => UnauthorizedFailure(message),
      404 => NotFoundFailure(message),
      429 => RateLimitedFailure(message),
      _ => ServerFailure(status, message),
    };
  }
}
