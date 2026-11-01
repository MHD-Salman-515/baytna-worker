import 'package:baytna_worker/core/network/json.dart';

/// A booking exactly as GET /workers/me/bookings returned it on staging
/// (BK-VLPE6F), with [overrides] applied.
Json bookingJson({
  String id = 'b1',
  String status = 'PENDING_WORKER',
  Json overrides = const {},
}) => {
  'id': id,
  'bookingNumber': 'BK-VLPE6F',
  'customerId': 'c1',
  'workerProfileId': 'w1',
  'serviceId': 's1',
  'workerServiceId': 'ws1',
  'countryId': 'sy',
  'cityId': 'damascus',
  'type': 'SCHEDULED',
  'status': status,
  'scheduledFor': '2026-11-05T07:00:00.000Z',
  'estimatedDurationMinutes': 180,
  'address': {'landmark': 'مقابل صيدلية الشفاء'},
  'pricing': {'pricingType': 'HOURLY', 'hours': 3, 'roomCount': null, 'workerEarnings': 15300, 'currency': 'SYP'},
  'finalPricing': null,
  'responseDeadline': '2026-11-02T21:36:01.677Z',
  'acceptedAt': null,
  'startedAt': null,
  'completedAt': null,
  'cancelledAt': null,
  'cancellation': null,
  'rejectionReason': null,
  'customerNote': null,
  'customerPhone': null,
  'customerRating': null,
  ...overrides,
};
