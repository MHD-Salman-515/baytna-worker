part of 'bookings_bloc.dart';

sealed class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load, or silently reload (pull, poll, back from a job).
final class BookingsRequested extends BookingsEvent {
  const BookingsRequested();
}

final class BookingsHistoryMoreRequested extends BookingsEvent {
  const BookingsHistoryMoreRequested();
}
