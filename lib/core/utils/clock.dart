import 'package:injectable/injectable.dart';

/// Current time, injectable so tests can pin "now" (expiry checks, "waiting
/// since …").
@injectable
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}
