part of 'booking_detail_bloc.dart';

final class BookingDetailState extends Equatable {
  const BookingDetailState({
    this.booking,
    this.context,
    this.minHours,
    this.commission,
    this.load = const DetailLoading(),
    this.action = const ActionIdle(),
  });

  final Booking? booking;
  final BookingContext? context;

  /// From her offering; the booking itself doesn't carry it.
  final int? minHours;

  /// The ledger line for this booking, once completed.
  final WalletEntry? commission;
  final DetailLoad load;
  final ActionStatus action;

  BookingDetailState copyWith({
    Booking? booking,
    BookingContext? context,
    int? minHours,
    WalletEntry? commission,
    DetailLoad? load,
    ActionStatus? action,
  }) => BookingDetailState(
    booking: booking ?? this.booking,
    context: context ?? this.context,
    minHours: minHours ?? this.minHours,
    commission: commission ?? this.commission,
    load: load ?? this.load,
    action: action ?? this.action,
  );

  @override
  List<Object?> get props => [booking, context, minHours, commission, load, action];
}

sealed class DetailLoad extends Equatable {
  const DetailLoad();

  @override
  List<Object?> get props => [];
}

final class DetailLoading extends DetailLoad {
  const DetailLoading();
}

final class DetailLoaded extends DetailLoad {
  const DetailLoaded();
}

final class DetailFailed extends DetailLoad {
  const DetailFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

sealed class ActionStatus extends Equatable {
  const ActionStatus();

  @override
  List<Object?> get props => [];
}

final class ActionIdle extends ActionStatus {
  const ActionIdle();
}

final class ActionRunning extends ActionStatus {
  const ActionRunning(this.action);

  /// Null for reject and cancel.
  final JobAction? action;

  @override
  List<Object?> get props => [action];
}

final class ActionFailed extends ActionStatus {
  const ActionFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
