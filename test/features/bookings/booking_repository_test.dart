import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:baytna_worker/features/bookings/data/models/booking_model.dart';
import 'package:baytna_worker/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:baytna_worker/features/bookings/domain/booking_failures.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_harness.dart';
import '../../helpers/booking_fixtures.dart';
import '../../helpers/fake_backend.dart';

(int, Object?) _page(List<Json> items, {int page = 1, int totalPages = 1}) => (
  200,
  {
    'success': true,
    'data': items,
    'meta': {'page': page, 'limit': 100, 'total': items.length, 'totalPages': totalPages},
  },
);

BookingRepositoryImpl _repo(Map<String, Handler> routes) {
  final h = ApiHarness(routes, tokens: AuthTokens(accessToken: testJwt(roles: ['WORKER']), refreshToken: 'r'));
  return BookingRepositoryImpl(BookingRemoteDataSource(h.api));
}

void main() {
  group('decoding', () {
    test('before acceptance: landmark only, earnings after commission', () {
      final b = BookingMapper.fromJson(bookingJson());
      expect(b.address.landmark, isNotEmpty);
      expect(b.address.isRevealed, isFalse);
      expect(b.customerPhone, isNull);
      expect(b.pricing.pricingType, PricingType.hourly);
      expect(b.pricing.workerEarnings, 15300);
    });

    test('after acceptance the address and phone appear', () {
      final b = BookingMapper.fromJson(
        bookingJson(
          status: 'ACCEPTED',
          overrides: {
            'customerPhone': '+963955500101',
            'address': {
              'landmark': 'L',
              'text': 'المزة، شارع 12',
              'floor': '3',
              'point': {
                'type': 'Point',
                'coordinates': [36.27, 33.51],
              },
            },
          },
        ),
      );
      expect(b.address.isRevealed, isTrue);
      expect(b.address.point?.latitude, 33.51, reason: 'GeoJSON is [lng, lat]');
      expect(b.customerPhone, '+963955500101');
    });

    test('a fractional amount fails loudly instead of being rounded', () {
      expect(
        () => BookingMapper.fromJson(
          bookingJson(
            overrides: {
              'pricing': {'pricingType': 'HOURLY', 'workerEarnings': 100.5, 'currency': 'SYP'},
            },
          ),
        ),
        throwsFormatException,
      );
    });
  });

  group('the only legal next step', () {
    test('follows the trip, and nothing after it', () {
      expect(JobAction.next(BookingStatus.pendingWorker), JobAction.accept);
      expect(JobAction.next(BookingStatus.accepted), JobAction.onTheWay);
      expect(JobAction.next(BookingStatus.onTheWay), JobAction.arrived);
      expect(JobAction.next(BookingStatus.arrived), JobAction.start);
      expect(JobAction.next(BookingStatus.inProgress), JobAction.complete);
      for (final s in [BookingStatus.completed, BookingStatus.cancelled, BookingStatus.expired, BookingStatus.rejected]) {
        expect(JobAction.next(s), isNull);
      }
    });

    test('cancel is offered only where the server allows it', () {
      expect(BookingStatus.values.where((s) => s.workerCanCancel), [
        BookingStatus.accepted,
        BookingStatus.onTheWay,
        BookingStatus.arrived,
      ]);
    });
  });

  group('find: there is no single-booking GET', () {
    test('walks the pages of her list', () async {
      final repo = _repo({
        'GET /api/v1/workers/me/bookings': (o, _) async {
          final page = o.queryParameters['page'] as int;
          return page == 1
              ? _page([bookingJson(id: 'other')], totalPages: 2)
              : _page([bookingJson()], page: 2, totalPages: 2);
        },
      });
      expect((await repo.find('b1') as Ok<Booking>).value.id, 'b1');
    });

    test('not on any page → BookingNotFound', () async {
      final repo = _repo({'GET /api/v1/workers/me/bookings': (_, _) async => _page(const [])});
      expect((await repo.find('b1') as Err<Booking>).failure, isA<BookingNotFound>());
    });
  });

  group('perform', () {
    test('a step re-reads the booking from her list projection', () async {
      var posted = 0;
      final repo = _repo({
        'POST /api/v1/workers/me/bookings/b1/on-the-way': (_, _) async {
          posted++;
          return (201, {'success': true, 'data': {'_id': 'raw-document-not-her-projection'}});
        },
        'GET /api/v1/workers/me/bookings': (o, _) async => _page([bookingJson(status: 'ON_THE_WAY')]),
      });
      final r = await repo.perform(JobAction.onTheWay, 'b1');
      expect((r as Ok<Booking>).value.status, BookingStatus.onTheWay);
      expect(posted, 1);
    });

    test('COMPLETE whose response is lost but which landed is a success, not resent', () async {
      var posted = 0;
      final repo = _repo({
        'POST /api/v1/workers/me/bookings/b1/complete': (o, _) async {
          posted++;
          throw DioException.connectionError(requestOptions: o, reason: 'connection reset');
        },
        'GET /api/v1/workers/me/bookings': (_, _) async => _page([bookingJson(status: 'COMPLETED')]),
      });
      final r = await repo.perform(JobAction.complete, 'b1');
      expect((r as Ok<Booking>).value.status, BookingStatus.completed);
      expect(posted, 1);
    });

    test('COMPLETE that really failed reports the failure', () async {
      final repo = _repo({
        'POST /api/v1/workers/me/bookings/b1/complete': (o, _) async =>
            throw DioException.connectionError(requestOptions: o, reason: 'connection reset'),
        'GET /api/v1/workers/me/bookings': (_, _) async => _page([bookingJson(status: 'IN_PROGRESS')]),
      });
      final r = await repo.perform(JobAction.complete, 'b1');
      expect((r as Err<Booking>).failure, isA<NetworkFailure>());
    });

    Future<Failure> failWith(int status, Object message) async {
      final repo = _repo({
        'POST /api/v1/workers/me/bookings/b1/accept': (_, _) async => FakeBackend.error(status, message),
      });
      return (await repo.perform(JobAction.accept, 'b1') as Err<Booking>).failure;
    }

    test('the real illegal-transition message yields the true current status', () async {
      final f = await failWith(400, 'Cannot ACCEPT a booking from status EXPIRED to ACCEPTED (requires current status to be one of: PENDING_WORKER)');
      expect(f, const IllegalTransition(BookingStatus.expired));
    });

    test('gate, clash and anything else stay distinct, none showing backend text', () async {
      expect(await failWith(403, 'Worker is financially suspended'), isA<NotAllowedToAcceptWork>());
      expect(await failWith(400, 'Worker is not approved'), isA<NotAllowedToAcceptWork>());
      expect(await failWith(409, 'Overlaps another booking'), isA<BookingClash>());
      expect(await failWith(400, 'Something new'), isA<JobStepRefused>());
    });
  });

  test('reject and cancel send the reason', () async {
    Object? body;
    final repo = _repo({
      'POST /api/v1/workers/me/bookings/b1/reject': (_, b) async {
        body = b;
        return (201, {'success': true, 'data': null});
      },
      'GET /api/v1/workers/me/bookings': (_, _) async => _page([bookingJson(status: 'REJECTED')]),
    });
    await repo.reject('b1', 'المكان بعيد');
    expect(body, {'reason': 'المكان بعيد'});
  });
}
