import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/availability/data/datasources/availability_remote_data_source.dart';
import 'package:baytna_worker/features/availability/data/repositories/availability_repository_impl.dart';
import 'package:baytna_worker/features/availability/domain/entities/availability.dart';
import 'package:baytna_worker/features/availability/domain/repositories/availability_repository.dart';
import 'package:baytna_worker/features/availability/presentation/bloc/availability/availability_bloc.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/api_harness.dart';
import '../../helpers/fake_backend.dart';

class _Countries extends Mock implements CountryRepository;

const _syria = Country(id: 'sy', code: 'SY', name: LocalizedText(ar: '', en: ''), phonePrefix: '+963', currencyCode: 'SYP', timezone: 'Asia/Damascus');

void main() {
  const am = TimeRange(start: '08:00', end: '12:00');
  const noon = TimeRange(start: '11:00', end: '14:00');
  const pm = TimeRange(start: '12:00', end: '14:00');

  test('validation mirrors the backend', () {
    expect(ScheduleValidator.dayError(const [TimeRange(start: '20:00', end: '08:00')]), ScheduleError.invalidRange);
    expect(ScheduleValidator.dayError(const [TimeRange(start: '09:00', end: '09:00')]), ScheduleError.invalidRange);
    expect(ScheduleValidator.dayError(const [am, noon]), ScheduleError.overlap);
    expect(ScheduleValidator.dayError(const [am, pm]), isNull, reason: 'touching is not overlapping');
    expect(
      ScheduleValidator.isValid(const AvailabilitySchedule(overrides: [DateOverride(date: '2026-12-01', type: OverrideType.extra)])),
      isFalse,
      reason: 'EXTRA needs times (400 otherwise)',
    );
  });

  test('round trip: weeklyWindows field, times as HH:mm, BLOCKED sends no times', () async {
    late Map<dynamic, dynamic> sent;
    final h = ApiHarness({
      'PUT /api/v1/workers/me/availability-windows': (_, body) async {
        sent = body! as Map<dynamic, dynamic>;
        return FakeBackend.ok({
          'weeklyWindows': [
            {'dayOfWeek': 1, 'startTime': '13:00', 'endTime': '14:00'},
            {'dayOfWeek': 1, 'startTime': '08:00', 'endTime': '12:00'},
          ],
          'dateOverrides': [
            {'date': '2026-12-20', 'type': 'BLOCKED', 'startTime': null, 'endTime': null},
          ],
        });
      },
    }, tokens: AuthTokens(accessToken: testJwt(roles: ['WORKER']), refreshToken: 'r'));
    final repo = AvailabilityRepositoryImpl(AvailabilityRemoteDataSource(h.api));

    final result = await repo.save(
      const AvailabilitySchedule(
        days: {1: [am]},
        overrides: [
          DateOverride(date: '2026-12-20', type: OverrideType.blocked, range: am),
          DateOverride(date: '2026-12-21', type: OverrideType.extra, range: am),
        ],
      ),
    );

    expect(sent['weeklyWindows'], [
      {'dayOfWeek': 1, 'startTime': '08:00', 'endTime': '12:00'},
    ]);
    expect(sent['dateOverrides'], [
      {'date': '2026-12-20', 'type': 'BLOCKED'},
      {'date': '2026-12-21', 'type': 'EXTRA', 'startTime': '08:00', 'endTime': '12:00'},
    ]);
    final saved = (result as Ok<AvailabilitySchedule>).value;
    expect(saved.days[1]!.map((r) => r.start), ['08:00', '13:00'], reason: 'sorted within a day');
    expect(saved.overrides.single.range, isNull);
  });

  group('bloc', () {
    Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 5));
    late _FakeRepo repo;
    late AvailabilityBloc bloc;

    setUp(() async {
      final countries = _Countries();
      when(() => countries.getById(any())).thenAnswer((_) async => const Ok(_syria));
      repo = _FakeRepo();
      bloc = AvailabilityBloc(repo, countries, 'sy')..add(const AvailabilityStarted());
      await pump();
    });

    tearDown(() => bloc.close());

    test('loads her COUNTRY timezone; edits are local until saved', () async {
      expect(bloc.state.timezone, 'Asia/Damascus');
      expect(bloc.state.hasChanges, isFalse);
      bloc.add(const AvailabilityDayToggled(3, enabled: true));
      await pump();
      expect(bloc.state.hasChanges, isTrue);
      expect(repo.saves, 0);
    });

    test('an overlapping day is not sent', () async {
      bloc
        ..add(const AvailabilityDayToggled(3, enabled: true))
        ..add(const AvailabilityRangeChanged(3, 0, am))
        ..add(const AvailabilityRangeAdded(3))
        ..add(const AvailabilityRangeChanged(3, 1, noon))
        ..add(const AvailabilitySaved());
      await pump();
      expect(bloc.state.status, const ScheduleInvalid());
      expect(repo.saves, 0);
    });

    test('turning a day off removes it; saving clears the draft', () async {
      bloc
        ..add(const AvailabilityDayToggled(1, enabled: false))
        ..add(const AvailabilitySaved());
      await pump();
      expect(repo.saves, 1);
      expect(repo.last.days.containsKey(1), isFalse);
      expect(bloc.state.status, const ScheduleSavedOk());
      expect(bloc.state.hasChanges, isFalse);
    });
  });
}

class _FakeRepo implements AvailabilityRepository {
  int saves = 0;
  late AvailabilitySchedule last;

  @override
  Future<Result<AvailabilitySchedule>> load() async => const Ok(
    AvailabilitySchedule(days: {1: [TimeRange(start: '08:00', end: '20:00')]}),
  );

  @override
  Future<Result<AvailabilitySchedule>> save(AvailabilitySchedule schedule) async {
    saves++;
    last = schedule;
    return Ok(schedule);
  }
}
