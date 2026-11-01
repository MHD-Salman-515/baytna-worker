import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Dates and times as the COUNTRY sees them, not the phone. A booking in
/// Damascus is at 10:00 Damascus time even if the phone is set to UTC (an
/// emulator) or the customer is abroad booking for her mother. Slot dates
/// (`YYYY-MM-DD`) are also in the country's zone (Swagger).
class CountryTime {
  CountryTime(String timezone) : _location = _resolve(timezone);

  final tz.Location _location;

  static bool _loaded = false;

  /// Idempotent; loads the zone database (bundled with the app) on first use.
  static void ensureInitialized() {
    if (_loaded) return;
    tzdata.initializeTimeZones();
    _loaded = true;
  }

  static tz.Location _resolve(String name) {
    ensureInitialized();
    try {
      return tz.getLocation(name);
    } on Object {
      // Unknown zone from the backend: UTC is wrong but visibly so, and the
      // server still validates every booking against its own clock.
      return tz.UTC;
    }
  }

  /// [instant] (any zone) as wall-clock time in the country.
  tz.TZDateTime local(DateTime instant) => tz.TZDateTime.from(instant, _location);

  /// Midnight of the country's calendar day [daysFromToday] after today.
  tz.TZDateTime day(DateTime now, int daysFromToday) {
    final today = local(now);
    return tz.TZDateTime(_location, today.year, today.month, today.day + daysFromToday);
  }

  /// `YYYY-MM-DD` of [instant] in the country.
  String dateKey(DateTime instant) {
    final d = local(instant);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}
