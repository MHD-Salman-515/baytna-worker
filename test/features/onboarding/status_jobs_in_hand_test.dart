import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/bookings/data/models/booking_model.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/bookings/domain/repositories/booking_repository.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:baytna_worker/features/onboarding/presentation/bloc/status/status_bloc.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/booking_fixtures.dart';

class _Workers extends Mock implements WorkerRepository;

class _Documents extends Mock implements DocumentRepository;

class _Bookings extends Mock implements BookingRepository;

Paged<Booking> _page(List<Booking> items) =>
    Paged(items: items, meta: const PageMeta(page: 1, limit: 100, total: 1, totalPages: 1));

void main() {
  late _Bookings bookings;
  late StatusBloc bloc;

  setUpAll(() => registerFallbackValue(BookingStatus.accepted));

  setUp(() {
    bookings = _Bookings();
    bloc = StatusBloc(_Workers(), _Documents(), bookings);
  });

  tearDown(() => bloc.close());

  void answer(BookingStatus status, Result<Paged<Booking>> result) =>
      when(() => bookings.list(status: status, limit: 100)).thenAnswer((_) async => result);

  Future<void> run() async {
    bloc.add(const StatusJobsRequested());
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }

  test('every active status is looked at: a job at any stage is found', () async {
    final working = BookingMapper.fromJson(bookingJson(status: 'IN_PROGRESS'));
    for (final s in BookingStatus.activeJob) {
      answer(s, Ok(_page(s == BookingStatus.inProgress ? [working] : const [])));
    }
    await run();
    expect(bloc.state.jobsInHand, [working]);
  });

  test('a failed refresh never hides a job she can see', () async {
    final working = BookingMapper.fromJson(bookingJson(status: 'IN_PROGRESS'));
    for (final s in BookingStatus.activeJob) {
      answer(s, Ok(_page(s == BookingStatus.inProgress ? [working] : const [])));
    }
    await run();
    answer(BookingStatus.accepted, const Err(NetworkFailure()));
    await run();
    expect(bloc.state.jobsInHand, [working]);
  });
}
