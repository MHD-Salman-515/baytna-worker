import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/availability/domain/entities/availability.dart';
import 'package:injectable/injectable.dart';

/// `{ weeklyWindows: [{dayOfWeek, startTime, endTime}],
///    dateOverrides: [{date, type, startTime, endTime}] }`. Note the field is
/// `weeklyWindows`. Both lists are required on PUT, even when empty.
@lazySingleton
class AvailabilityRemoteDataSource {
  AvailabilityRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AvailabilitySchedule> load() =>
      _api.get('/workers/me/availability-windows', decode: _decode);

  Future<AvailabilitySchedule> save(AvailabilitySchedule schedule) => _api.put(
    '/workers/me/availability-windows',
    body: _encode(schedule),
    decode: _decode,
  );

  static AvailabilitySchedule _decode(Object? data) {
    final json = asJson(data);
    final days = <int, List<TimeRange>>{};
    for (final w in asJsonList(json['weeklyWindows'])) {
      (days[(w['dayOfWeek'] as num).toInt()] ??= []).add(
        TimeRange(start: w['startTime'] as String, end: w['endTime'] as String),
      );
    }
    for (final ranges in days.values) {
      ranges.sort((a, b) => a.start.compareTo(b.start));
    }
    return AvailabilitySchedule(
      days: days,
      overrides: [
        for (final o in asJsonList(json['dateOverrides']))
          DateOverride(
            date: o['date'] as String,
            type: OverrideType.fromApi(o['type']),
            range: o['startTime'] is String && o['endTime'] is String
                ? TimeRange(start: o['startTime'] as String, end: o['endTime'] as String)
                : null,
          ),
      ],
    );
  }

  static Json _encode(AvailabilitySchedule s) => {
    'weeklyWindows': [
      for (final MapEntry(key: day, value: ranges) in s.days.entries)
        for (final r in ranges) {'dayOfWeek': day, 'startTime': r.start, 'endTime': r.end},
    ],
    'dateOverrides': [
      for (final o in s.overrides)
        {
          'date': o.date,
          'type': o.type.apiValue,
          if (o.type == OverrideType.extra && o.range != null) ...{
            'startTime': o.range!.start,
            'endTime': o.range!.end,
          },
        },
    ],
  };
}
