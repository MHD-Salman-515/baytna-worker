import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';

sealed class BookingFailure extends FeatureFailure {
  const BookingFailure([super.debugMessage]);
}

/// 400 "Cannot ACCEPT a booking from status EXPIRED to ACCEPTED (requires …)".
/// Her screen was stale: the booking moved on (it expired, or the customer
/// cancelled). [current] says where it actually is.
final class IllegalTransition extends BookingFailure {
  const IllegalTransition(this.current, [super.debugMessage]);

  final BookingStatus current;

  @override
  List<Object?> get props => [current];
}

/// The server refused NEW work because of a gate (financial or verification).
final class NotAllowedToAcceptWork extends BookingFailure {
  const NotAllowedToAcceptWork([super.debugMessage]);
}

/// 409: the slot now clashes with another of her jobs.
final class BookingClash extends BookingFailure {
  const BookingClash([super.debugMessage]);
}

/// Any other refusal of a step. The app never shows backend English.
final class JobStepRefused extends BookingFailure {
  const JobStepRefused([super.debugMessage]);
}

/// She isn't on this booking, or it no longer exists.
final class BookingNotFound extends BookingFailure {
  const BookingNotFound([super.debugMessage]);
}
