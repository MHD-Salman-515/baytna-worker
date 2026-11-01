import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/bookings/domain/booking_context.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/bookings/domain/repositories/booking_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

/// Her jobs in three lists: requests awaiting her answer, jobs she accepted,
/// and history. The backend filters by ONE status, so the active list is one
/// request per active status.
@injectable
class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc(this._repository, this._context, @factoryParam String countryId)
    : _countryId = countryId,
      super(const BookingsState()) {
    on<BookingsRequested>(_onRequested);
    on<BookingsHistoryMoreRequested>(_onHistoryMore);
  }

  final BookingRepository _repository;
  final BookingContextLoader _context;
  final String _countryId;

  Future<void> _onRequested(BookingsRequested event, Emitter<BookingsState> emit) async {
    if (state.load is! BookingsLoaded) emit(state.copyWith(load: const BookingsLoading()));
    final context = await _context.load(_countryId);
    final results = await Future.wait([
      _repository.list(status: BookingStatus.pendingWorker, limit: 100),
      for (final s in BookingStatus.activeJob) _repository.list(status: s, limit: 100),
    ]);
    final history = await _repository.list();

    final failure = switch (context) {
      Err(:final failure) => failure,
      Ok() => [...results, history].whereType<Err<Paged<Booking>>>().firstOrNull?.failure,
    };
    if (failure != null) {
      // A background refresh failing keeps what she can already see.
      if (state.load is! BookingsLoaded) emit(state.copyWith(load: BookingsFailed(failure)));
      return;
    }

    List<Booking> items(Result<Paged<Booking>> r) => (r as Ok<Paged<Booking>>).value.items;
    final historyPage = (history as Ok<Paged<Booking>>).value;
    emit(
      state.copyWith(
        context: (context as Ok<BookingContext>).value,
        requests: _soonestFirst(items(results.first)),
        active: _soonestFirst([for (final r in results.skip(1)) ...items(r)]),
        history: historyPage.items.where((b) => b.status.isFinished).toList(),
        historyPage: 1,
        hasMoreHistory: historyPage.meta.hasNext,
        load: const BookingsLoaded(),
      ),
    );
  }

  Future<void> _onHistoryMore(BookingsHistoryMoreRequested event, Emitter<BookingsState> emit) async {
    if (!state.hasMoreHistory || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.historyPage + 1;
    switch (await _repository.list(page: next)) {
      case Ok(:final value):
        emit(
          state.copyWith(
            history: [...state.history, ...value.items.where((b) => b.status.isFinished)],
            historyPage: next,
            hasMoreHistory: value.meta.hasNext,
            loadingMore: false,
          ),
        );
      case Err():
        emit(state.copyWith(loadingMore: false));
    }
  }

  static List<Booking> _soonestFirst(List<Booking> list) => [...list]
    ..sort((a, b) {
      final x = a.scheduledFor;
      final y = b.scheduledFor;
      if (x == null || y == null) return 0;
      return x.compareTo(y);
    });
}
