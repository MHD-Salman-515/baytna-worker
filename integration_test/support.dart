import 'package:baytna_worker/core/dev/dev_otp.dart';
import 'package:baytna_worker/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Shared driving for the live E2E runs: waits, screenshots, a request log
/// handed to the driver (build/e2e_screenshots/log.txt), and sign-in.
class E2E {
  E2E(this.binding, this.tester);

  final IntegrationTestWidgetsFlutterBinding binding;
  final WidgetTester tester;
  final DateTime _started = DateTime.now();
  final List<String> _log = [];
  DebugPrintCallback? _original;

  void log(String message) => debugPrint('[e2e] $message');

  void startLogging() {
    _original = debugPrint;
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      final t = DateTime.now().difference(_started).inMilliseconds / 1000;
      if (message != null) _log.add('${t.toStringAsFixed(1).padLeft(7)}s  $message');
      original(message, wrapWidth: wrapWidth);
    };
  }

  void stopLogging() {
    debugPrint = _original ?? debugPrint;
    (binding.reportData ??= <String, dynamic>{})['log'] = _log;
  }

  Future<void> waitFor(Finder finder, {int seconds = 120}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out after ${seconds}s waiting for $finder');
  }

  Future<void> settle([Duration d = const Duration(milliseconds: 800)]) async {
    final end = DateTime.now().add(d);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(String name) async {
    await settle(const Duration(milliseconds: 600));
    await binding.takeScreenshot(name);
  }

  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await settle(const Duration(milliseconds: 300));
    await tester.tap(finder);
    await tester.pump();
  }

  /// The system back gesture.
  Future<void> back() async {
    await tester.binding.handlePopRoute();
    await settle();
  }

  String textOf(String key) => tester.widget<Text>(find.byKey(ValueKey(key))).data ?? '';

  /// Launches the app and signs in through the real UI with the dev OTP.
  Future<void> launchAndSignIn(String phone) async {
    expect(DevOtp.enabled, isTrue, reason: 'Run with --dart-define-from-file=secrets.json');
    await app.main();
    if (defaultTargetPlatform == TargetPlatform.android) await binding.convertFlutterSurfaceToImage();
    // A session kept from an earlier run needs no OTP (staging throttles them).
    final jobs = find.byKey(const ValueKey('tab-jobs'));
    final country = find.byKey(const ValueKey('country-SY'));
    await waitFor(find.byWidgetPredicate((w) => w.key == const ValueKey('tab-jobs') || w.key == const ValueKey('country-SY')));
    if (jobs.evaluate().isNotEmpty) {
      log('already signed in');
      return;
    }
    await tester.tap(country);
    await waitFor(find.byKey(const ValueKey('phone-field')));
    await tester.enterText(find.byKey(const ValueKey('phone-field')), phone);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('send-code')));
    await waitFor(find.byKey(const ValueKey('dev-otp-fill')), seconds: 90);
    await tester.tap(find.byKey(const ValueKey('dev-otp-fill')));
    await waitFor(find.byKey(const ValueKey('tab-jobs')), seconds: 90);
    log('signed in as $phone');
  }
}
