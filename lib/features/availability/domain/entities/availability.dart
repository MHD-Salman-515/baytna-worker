import 'package:equatable/equatable.dart';

/// `HH:mm`, as the backend requires it, in her COUNTRY's timezone. Kept as
/// text on purpose: a `DateTime` would invite conversion to the phone's zone.
/// Zero-padded, so plain string comparison orders it correctly.
class TimeRange extends Equatable {
  const TimeRange({required this.start, required this.end});

  final String start;
  final String end;

  bool get isValid => start.compareTo(end) < 0;

  bool overlaps(TimeRange other) => start.compareTo(other.end) < 0 && other.start.compareTo(end) < 0;

  @override
  List<Object?> get props => [start, end];
}

enum OverrideType {
  /// Not working that day, whatever the week says.
  blocked('BLOCKED'),

  /// Extra hours on top of the week.
  extra('EXTRA');

  OverrideType(this.apiValue);

  final String apiValue;

  static OverrideType fromApi(Object? value) => value == 'EXTRA' ? extra : blocked;
}

class DateOverride extends Equatable {
  const DateOverride({required this.date, required this.type, this.range});

  /// `YYYY-MM-DD`, a calendar day in her country.
  final String date;
  final OverrideType type;

  /// Required for EXTRA; the backend drops it for BLOCKED.
  final TimeRange? range;

  @override
  List<Object?> get props => [date, type, range];
}

/// GET/PUT /workers/me/availability-windows. Days use the backend's numbering
/// (0 = Sunday … 6 = Saturday); a day with no ranges is a day off.
class AvailabilitySchedule extends Equatable {
  const AvailabilitySchedule({this.days = const {}, this.overrides = const []});

  final Map<int, List<TimeRange>> days;
  final List<DateOverride> overrides;

  @override
  List<Object?> get props => [days, overrides];
}

enum ScheduleError {
  /// A range that doesn't start before it ends.
  invalidRange,

  /// Two ranges on one day overlap.
  overlap,
}

abstract final class ScheduleValidator {
  /// The same checks the backend makes, per day.
  static ScheduleError? dayError(List<TimeRange> ranges) {
    if (ranges.any((r) => !r.isValid)) return ScheduleError.invalidRange;
    for (var i = 0; i < ranges.length; i++) {
      for (var j = i + 1; j < ranges.length; j++) {
        if (ranges[i].overlaps(ranges[j])) return ScheduleError.overlap;
      }
    }
    return null;
  }

  static bool isValid(AvailabilitySchedule schedule) =>
      schedule.days.values.every((r) => dayError(r) == null) &&
      schedule.overrides.every((o) => o.type == OverrideType.blocked || (o.range?.isValid ?? false));
}
