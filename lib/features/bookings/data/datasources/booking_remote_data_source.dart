import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/features/bookings/data/models/booking_model.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BookingRemoteDataSource {
  BookingRemoteDataSource(this._api);

  final ApiClient _api;

  /// The backend caps `limit` at 100.
  static const maxPageSize = 100;

  Future<Paged<Booking>> list({BookingStatus? status, int page = 1, int limit = 20}) => _api.getPage(
    '/workers/me/bookings',
    query: {'status': ?status?.apiValue, 'page': page, 'limit': limit},
    decodeItem: BookingMapper.fromJson,
  );

  /// The answer's shape isn't relied on (see BookingRepositoryImpl).
  Future<Booking?> perform(JobAction action, String id) =>
      _api.post('/workers/me/bookings/$id/${action.path}', decode: BookingMapper.tryFromJson);

  Future<Booking?> reject(String id, String reason) => _api.post(
    '/workers/me/bookings/$id/reject',
    body: {'reason': reason},
    decode: BookingMapper.tryFromJson,
  );

  Future<Booking?> cancel(String id, String reason) => _api.post(
    '/workers/me/bookings/$id/cancel',
    body: {'reason': reason},
    decode: BookingMapper.tryFromJson,
  );
}
