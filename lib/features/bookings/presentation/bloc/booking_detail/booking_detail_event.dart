part of 'booking_detail_bloc.dart';

sealed class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load, or silently reload (pull, deadline reached, app resumed).
final class BookingDetailRequested extends BookingDetailEvent {
  const BookingDetailRequested();
}

final class JobActionRequested extends BookingDetailEvent {
  const JobActionRequested(this.action);

  final JobAction action;

  @override
  List<Object?> get props => [action];
}

final class BookingRejectRequested extends BookingDetailEvent {
  const BookingRejectRequested(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}

final class BookingCancelRequested extends BookingDetailEvent {
  const BookingCancelRequested(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}
