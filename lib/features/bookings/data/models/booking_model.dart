import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/geo/geo_point.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';

/// Decodes an element of GET /workers/me/bookings. Verified on staging for
/// PENDING/EXPIRED/CANCELLED bookings:
///
/// ```json
/// { "id", "bookingNumber", "customerId", "workerProfileId", "serviceId",
///   "workerServiceId", "countryId", "cityId", "type": "SCHEDULED", "status",
///   "scheduledFor", "estimatedDurationMinutes",
///   "address": { "landmark": "…" },           // landmark ONLY until accepted
///   "pricing": { "pricingType", "hours", "roomCount", "workerEarnings", "currency" },
///   "finalPricing": null, "responseDeadline", "acceptedAt", "startedAt",
///   "completedAt", "cancelledAt", "cancellation", "rejectionReason",
///   "customerNote", "customerPhone": null, "customerRating": null }
/// ```
///
/// The projection hides the customer's price and the commission rate.
abstract final class BookingMapper {
  static Booking fromJson(Json json) => Booking(
    id: json['id'] as String,
    bookingNumber: json['bookingNumber'] as String? ?? '',
    status: BookingStatus.fromApi(json['status']),
    serviceId: json['serviceId'] as String,
    workerServiceId: json['workerServiceId'] as String?,
    countryId: json['countryId'] as String,
    cityId: json['cityId'] as String,
    scheduledFor: _date(json['scheduledFor']),
    estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
    address: _address(json['address']),
    pricing: _pricing(asJson(json['pricing'])),
    finalPricing: json['finalPricing'] == null ? null : _pricing(asJson(json['finalPricing'])),
    responseDeadline: _date(json['responseDeadline']),
    acceptedAt: _date(json['acceptedAt']),
    startedAt: _date(json['startedAt']),
    completedAt: _date(json['completedAt']),
    cancelledAt: _date(json['cancelledAt']),
    cancellation: _cancellation(json['cancellation']),
    rejectionReason: json['rejectionReason'] as String?,
    customerNote: json['customerNote'] as String?,
    customerPhone: json['customerPhone'] as String?,
  );

  /// A POST may answer with the raw document instead of her projection.
  static Booking? tryFromJson(Object? data) {
    try {
      return fromJson(asJson(data));
    } on Object {
      return null;
    }
  }

  static DateTime? _date(Object? raw) => raw is String ? DateTime.tryParse(raw) : null;

  static BookingAddress _address(Object? raw) {
    final json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
    return BookingAddress(
      landmark: json['landmark'] as String? ?? '',
      text: json['text'] as String?,
      floor: json['floor'] as String?,
      notes: json['notes'] as String?,
      point: GeoPoint.tryFromGeoJson(json['point']),
    );
  }

  static BookingPricing _pricing(Json json) => BookingPricing(
    pricingType: PricingType.fromApi(json['pricingType']),
    currency: json['currency'] as String,
    workerEarnings: moneyFromJsonOrNull(json['workerEarnings']),
    hours: json['hours'] as num?,
    roomCount: (json['roomCount'] as num?)?.toInt(),
  );

  static BookingCancellation? _cancellation(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    return BookingCancellation(
      byRole: raw['byRole'] as String? ?? '',
      reason: raw['reason'] as String?,
      feeAmount: moneyFromJsonOrNull(raw['feeAmount']),
    );
  }
}
