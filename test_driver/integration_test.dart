import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Host-side driver: saves screenshots taken by the integration test, and the
/// app log it captured, to build/e2e_screenshots/ (gitignored via /build/).
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final log =
        (data?['log'] as List<dynamic>?)?.join('\n') ?? '(no log captured)';
    final file = File('build/e2e_screenshots/log.txt');
    await file.create(recursive: true);
    await file.writeAsString('$log\n');
  },
  onScreenshot: (name, bytes, [args]) async {
    final file = File('build/e2e_screenshots/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return true;
  },
);
