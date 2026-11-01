import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/geo/geo_point.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:equatable/equatable.dart';

enum BookingStatus {
  searching('SEARCHING'),
  pendingWorker('PENDING_WORKER'),
  accepted('ACCEPTED'),
  onTheWay('ON_THE_WAY'),
  arrived('ARRIVED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  expired('EXPIRED'),
  noWorkerFound('NO_WORKER_FOUND'),
  noShow('NO_SHOW'),
  unknown('');

  BookingStatus(this.apiValue);

  final String apiValue;

  static BookingStatus fromApi(Object? value) =>
      values.firstWhere((s) => s.apiValue == value && s != unknown, orElse: () => unknown);

  /// Accepted and not finished: she owes this job, whatever her wallet says.
  static const List<BookingStatus> activeJob = [accepted, onTheWay, arrived, inProgress];

  bool get isActiveJob => activeJob.contains(this);

  bool get isFinished => const {completed, rejected, cancelled, expired, noWorkerFound, noShow}.contains(this);

  /// From the backend's own transition error: "requires current status to be
  /// one of: ACCEPTED, ON_THE_WAY, ARRIVED". Not IN_PROGRESS.
  bool get workerCanCancel => const {accepted, onTheWay, arrived}.contains(this);
}

/// One step of the trip, each its own POST under /workers/me/bookings/:id/.
/// The server enforces order and actor; the app only offers the next step.
enum JobAction {
  accept('accept', BookingStatus.accepted),
  onTheWay('on-the-way', BookingStatus.onTheWay),
  arrived('arrived', BookingStatus.arrived),
  start('start', BookingStatus.inProgress),
  complete('complete', BookingStatus.completed);

  JobAction(this.path, this.target);

  final String path;

  /// The status this step leads to.
  final BookingStatus target;

  /// The one legal next step from [status], if any. Accepting is decided on
  /// its own screen section, next to rejecting.
  static JobAction? next(BookingStatus status) => switch (status) {
    BookingStatus.pendingWorker => accept,
    BookingStatus.accepted => onTheWay,
    BookingStatus.onTheWay => arrived,
    BookingStatus.arrived => start,
    BookingStatus.inProgress => complete,
    _ => null,
  };
}

/// Before she accepts, the backend sends ONLY [landmark]: no pin, no street,
/// no floor. Everything else appears after acceptance.
class BookingAddress extends Equatable {
  const BookingAddress({required this.landmark, this.text, this.floor, this.notes, this.point});

  final String landmark;
  final String? text;
  final String? floor;
  final String? notes;
  final GeoPoint? point;

  bool get isRevealed => text != null || point != null;

  @override
  List<Object?> get props => [landmark, text, floor, notes, point];
}

/// The price frozen at creation, as a WORKER sees it: her estimated earnings
/// after commission. There is no customer price in this projection.
class BookingPricing extends Equatable {
  const BookingPricing({
    required this.pricingType,
    required this.currency,
    this.workerEarnings,
    this.hours,
    this.roomCount,
  });

  final PricingType pricingType;
  final String currency;
  final int? workerEarnings;

  /// Estimated hours (HOURLY).
  final num? hours;
  final int? roomCount;

  Money? get earnings => workerEarnings == null ? null : Money(workerEarnings!, currency);

  @override
  List<Object?> get props => [pricingType, currency, workerEarnings, hours, roomCount];
}

class BookingCancellation extends Equatable {
  const BookingCancellation({required this.byRole, this.reason, this.feeAmount});

  final String byRole;
  final String? reason;
  final int? feeAmount;

  bool get byCustomer => byRole == 'CUSTOMER';

  @override
  List<Object?> get props => [byRole, reason, feeAmount];
}

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.serviceId,
    required this.countryId,
    required this.cityId,
    required this.scheduledFor,
    required this.estimatedDurationMinutes,
    required this.address,
    required this.pricing,
    this.workerServiceId,
    this.finalPricing,
    this.responseDeadline,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellation,
    this.rejectionReason,
    this.customerNote,
    this.customerPhone,
  });

  final String id;
  final String bookingNumber;
  final BookingStatus status;
  final String serviceId;
  final String? workerServiceId;
  final String countryId;
  final String cityId;
  final DateTime? scheduledFor;
  final int estimatedDurationMinutes;
  final BookingAddress address;
  final BookingPricing pricing;

  /// Set at completion. For HOURLY it is recomputed from ACTUAL time.
  final BookingPricing? finalPricing;

  /// She must answer by then, or the booking EXPIRES.
  final DateTime? responseDeadline;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final BookingCancellation? cancellation;
  final String? rejectionReason;
  final String? customerNote;

  /// Null until she accepts.
  final String? customerPhone;

  @override
  List<Object?> get props => [
    id,
    bookingNumber,
    status,
    serviceId,
    workerServiceId,
    countryId,
    cityId,
    scheduledFor,
    estimatedDurationMinutes,
    address,
    pricing,
    finalPricing,
    responseDeadline,
    acceptedAt,
    startedAt,
    completedAt,
    cancelledAt,
    cancellation,
    rejectionReason,
    customerNote,
    customerPhone,
  ];
}
