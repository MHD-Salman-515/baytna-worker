import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// App-wide "the server is waking up" signal. True while at least one request
/// has been in flight longer than `AppConfig.slowRequestThreshold`, or while a
/// cold-start retry is pending. A banner in `app.dart` listens to it, so every
/// screen gets the waking-up state for free instead of failing.
@lazySingleton
class ServerStatus {
  final ValueNotifier<bool> _wakingUp = ValueNotifier(false);
  int _slowRequests = 0;

  ValueListenable<bool> get wakingUp => _wakingUp;

  void slowRequestStarted() {
    _slowRequests++;
    _wakingUp.value = true;
  }

  void slowRequestEnded() {
    if (_slowRequests > 0) _slowRequests--;
    _wakingUp.value = _slowRequests > 0;
  }
}
