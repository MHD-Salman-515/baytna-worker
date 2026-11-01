import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';

abstract interface class BookingRepository {
  /// One page, optionally one status (the backend filters by a single value).
  Future<Result<Paged<Booking>>> list({BookingStatus? status, int page = 1, int limit = 20});

  /// There is NO single-booking GET for workers (GET /bookings/:id is 404 for
  /// her), so this searches her list. Fails with `BookingNotFound`.
  Future<Result<Booking>> find(String id, {BookingStatus? expectedStatus});

  /// Performs one step and returns the booking as it now stands. A response
  /// lost on a bad connection is not retried blindly: the status is re-read,
  /// and if the step landed, that's a success. Never fires the POST twice.
  Future<Result<Booking>> perform(JobAction action, String id);

  /// [reason] is required by the backend.
  Future<Result<Booking>> reject(String id, String reason);

  /// After accepting, before the work starts. [reason] is required.
  Future<Result<Booking>> cancel(String id, String reason);
}
