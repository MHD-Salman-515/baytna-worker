import 'package:injectable/injectable.dart';

/// Countdown source, injectable so bloc tests can run countdowns instantly.
@injectable
class Ticker {
  const Ticker();

  /// Emits from-1, from-2, … 0, one per second.
  Stream<int> countdown(int from) => Stream<int>.periodic(
    const Duration(seconds: 1),
    (i) => from - i - 1,
  ).take(from);
}
