import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:baytna_worker/features/bookings/domain/booking_failures.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/bookings/domain/repositories/booking_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  /// Upper bound on the search, so it can't page forever.
  static const _maxSearchPages = 10;

  @override
  Future<Result<Paged<Booking>>> list({BookingStatus? status, int page = 1, int limit = 20}) =>
      guard(() => _remote.list(status: status, page: page, limit: limit));

  @override
  Future<Result<Booking>> find(String id, {BookingStatus? expectedStatus}) => guard(() async {
    // The expected status is a much shorter list; fall back to everything.
    if (expectedStatus != null) {
      final hit = await _search(id, status: expectedStatus);
      if (hit != null) return hit;
    }
    final hit = await _search(id);
    if (hit == null) throw BookingNotFound('Booking $id');
    return hit;
  });

  Future<Booking?> _search(String id, {BookingStatus? status}) async {
    for (var page = 1; page <= _maxSearchPages; page++) {
      final batch = await _remote.list(
        status: status,
        page: page,
        limit: BookingRemoteDataSource.maxPageSize,
      );
      final hit = batch.items.where((b) => b.id == id).firstOrNull;
      if (hit != null) return hit;
      if (!batch.meta.hasNext) return null;
    }
    return null;
  }

  @override
  Future<Result<Booking>> perform(JobAction action, String id) => _act(
    id,
    action.target,
    () => _remote.perform(action, id),
    gated: action == JobAction.accept,
  );

  @override
  Future<Result<Booking>> reject(String id, String reason) =>
      _act(id, BookingStatus.rejected, () => _remote.reject(id, reason));

  @override
  Future<Result<Booking>> cancel(String id, String reason) =>
      _act(id, BookingStatus.cancelled, () => _remote.cancel(id, reason));

  /// [gated]: only ACCEPTING is new work, so only there may a refusal be read
  /// as the two gates. A refused step on a job in hand is something else.
  Future<Result<Booking>> _act(
    String id,
    BookingStatus target,
    Future<Booking?> Function() post, {
    bool gated = false,
  }) async {
    final result = await guard(post);
    switch (result) {
      case Ok(:final value):
        // Her list projection is the shape everything else reads (the POST
        // answer may be the raw document). Prefer it; fall back to the answer.
        final fresh = await find(id, expectedStatus: target);
        if (fresh is Ok<Booking>) return fresh;
        if (value != null) return Ok(value);
        return fresh;
      case Err(:final failure) when _isAmbiguous(failure):
        // The step may have landed with only the response lost. On `complete`
        // that is real money, so look before reporting anything.
        final current = await find(id, expectedStatus: target);
        if (current case Ok(value: final Booking booking) when booking.status == target) {
          debugPrint('[bookings] response lost, but ${booking.bookingNumber} is ${target.apiValue}');
          return current;
        }
        return Err(failure);
      case Err(:final failure):
        return Err(_mapped(failure, gated: gated));
    }
  }

  static bool _isAmbiguous(Failure f) => switch (f) {
    NetworkFailure() || TimeoutFailure() => true,
    ServerFailure(:final statusCode) => statusCode == null || statusCode >= 500,
    _ => false,
  };

  static final _fromStatus = RegExp('from status ([A-Z_]+)');

  /// Observed: "Cannot ACCEPT a booking from status EXPIRED to ACCEPTED
  /// (requires current status to be one of: PENDING_WORKER)".
  static Failure _mapped(Failure f, {required bool gated}) {
    switch (f) {
      case ValidationFailure(:final messages):
        final message = messages.join(' ');
        final from = _fromStatus.firstMatch(message);
        if (from != null) return IllegalTransition(BookingStatus.fromApi(from[1]), f.debugMessage);
        return gated && _isGate(message) ? NotAllowedToAcceptWork(f.debugMessage) : JobStepRefused(f.debugMessage);
      case UnauthorizedFailure(:final debugMessage):
        if (!gated) return JobStepRefused(debugMessage);
        return _isGate(debugMessage ?? '') ? NotAllowedToAcceptWork(debugMessage) : f;
      case NotFoundFailure(:final debugMessage):
        return BookingNotFound(debugMessage);
      case ServerFailure(statusCode: 409, :final debugMessage):
        return BookingClash(debugMessage);
      default:
        return f;
    }
  }

  static bool _isGate(String message) {
    final m = message.toLowerCase();
    return m.contains('suspend') || m.contains('financial') || m.contains('not approved') || m.contains('verified');
  }
}
