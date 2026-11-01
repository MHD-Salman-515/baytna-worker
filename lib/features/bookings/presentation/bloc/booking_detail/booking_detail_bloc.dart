import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/bookings/domain/booking_context.dart';
import 'package:baytna_worker/features/bookings/domain/booking_failures.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/bookings/domain/repositories/booking_repository.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';
import 'package:baytna_worker/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

/// One booking: the decision, then the trip, then the money.
@injectable
class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  BookingDetailBloc(
    this._bookings,
    this._context,
    this._offerings,
    this._wallet,
    @factoryParam String id,
    @factoryParam String countryId,
  ) : _id = id,
      _countryId = countryId,
      super(const BookingDetailState()) {
    on<BookingDetailRequested>(_onRequested);
    on<JobActionRequested>(_onAction);
    on<BookingRejectRequested>(_onReject);
    on<BookingCancelRequested>(_onCancel);
  }

  final BookingRepository _bookings;
  final BookingContextLoader _context;
  final OfferingRepository _offerings;
  final WalletRepository _wallet;
  final String _id;
  final String _countryId;

  Future<void> _onRequested(BookingDetailRequested event, Emitter<BookingDetailState> emit) async {
    final (booking, context) = await (_bookings.find(_id), _context.load(_countryId)).wait;
    switch ((booking, context)) {
      case (Ok(value: final b), Ok(value: final c)):
        emit(state.copyWith(booking: b, context: c, load: const DetailLoaded()));
        await _loadExtras(b, emit);
      case (Err(:final failure), _) || (_, Err(:final failure)):
        // A background refresh failing keeps what she can already see.
        if (state.booking == null) emit(state.copyWith(load: DetailFailed(failure)));
    }
  }

  Future<void> _onAction(JobActionRequested event, Emitter<BookingDetailState> emit) async {
    await _step(emit, event.action, () => _bookings.perform(event.action, _id));
  }

  Future<void> _onReject(BookingRejectRequested event, Emitter<BookingDetailState> emit) async {
    await _step(emit, null, () => _bookings.reject(_id, event.reason));
  }

  Future<void> _onCancel(BookingCancelRequested event, Emitter<BookingDetailState> emit) async {
    await _step(emit, null, () => _bookings.cancel(_id, event.reason));
  }

  Future<void> _step(
    Emitter<BookingDetailState> emit,
    JobAction? action,
    Future<Result<Booking>> Function() run,
  ) async {
    if (state.action is ActionRunning) return;
    emit(state.copyWith(action: ActionRunning(action)));
    switch (await run()) {
      case Ok(value: final booking):
        emit(state.copyWith(booking: booking, action: const ActionIdle()));
        await _loadExtras(booking, emit);
      case Err(:final IllegalTransition failure):
        // Her screen was stale: show where the booking really is, and why.
        final fresh = await _bookings.find(_id);
        emit(
          state.copyWith(
            booking: fresh is Ok<Booking> ? fresh.value : null,
            action: ActionFailed(failure),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(action: ActionFailed(failure)));
    }
  }

  /// What the money explanation needs. Best effort: the figures on the
  /// booking stand on their own without these.
  Future<void> _loadExtras(Booking booking, Emitter<BookingDetailState> emit) async {
    if (state.minHours == null && booking.pricing.pricingType == PricingType.hourly) {
      if (await _offerings.getOfferings() case Ok(:final value)) {
        final price = value.where((o) => o.id == booking.workerServiceId).firstOrNull?.price;
        if (price is HourlyPrice) emit(state.copyWith(minHours: price.minHours));
      }
    }
    if (booking.status == BookingStatus.completed) {
      if (await _wallet.commissionFor(booking.id) case Ok(value: final WalletEntry entry)) {
        emit(state.copyWith(commission: entry));
      }
    }
  }
}
