import 'dart:async';

import 'package:injectable/injectable.dart';

/// Bridge from the network layer to the AuthBloc: the refresher announces an
/// unrecoverable session here and the AuthBloc signs the user out. Keeps the
/// network layer free of any dependency on presentation code.
@lazySingleton
class SessionEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Stream<void> get onExpired => _expired.stream;

  void notifyExpired() => _expired.add(null);

  @disposeMethod
  Future<void> dispose() => _expired.close();
}
