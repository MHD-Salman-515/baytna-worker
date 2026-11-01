part of 'bookings_bloc.dart';

final class BookingsState extends Equatable {
  const BookingsState({
    this.context,
    this.requests = const [],
    this.active = const [],
    this.history = const [],
    this.historyPage = 1,
    this.hasMoreHistory = false,
    this.loadingMore = false,
    this.load = const BookingsLoading(),
  });

  final BookingContext? context;

  /// PENDING_WORKER, awaiting her answer before the deadline.
  final List<Booking> requests;

  /// Accepted and not finished.
  final List<Booking> active;
  final List<Booking> history;
  final int historyPage;
  final bool hasMoreHistory;
  final bool loadingMore;
  final BookingsLoadStatus load;

  BookingsState copyWith({
    BookingContext? context,
    List<Booking>? requests,
    List<Booking>? active,
    List<Booking>? history,
    int? historyPage,
    bool? hasMoreHistory,
    bool? loadingMore,
    BookingsLoadStatus? load,
  }) => BookingsState(
    context: context ?? this.context,
    requests: requests ?? this.requests,
    active: active ?? this.active,
    history: history ?? this.history,
    historyPage: historyPage ?? this.historyPage,
    hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
    loadingMore: loadingMore ?? this.loadingMore,
    load: load ?? this.load,
  );

  @override
  List<Object?> get props => [context, requests, active, history, historyPage, hasMoreHistory, loadingMore, load];
}

sealed class BookingsLoadStatus extends Equatable {
  const BookingsLoadStatus();

  @override
  List<Object?> get props => [];
}

final class BookingsLoading extends BookingsLoadStatus {
  const BookingsLoading();
}

final class BookingsLoaded extends BookingsLoadStatus {
  const BookingsLoaded();
}

final class BookingsFailed extends BookingsLoadStatus {
  const BookingsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
