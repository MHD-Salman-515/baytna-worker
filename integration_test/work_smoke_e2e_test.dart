import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support.dart';

/// READ-ONLY tour of the approved worker's app against LIVE staging. Saves
/// nothing, accepts nothing.
///
///   flutter drive -d emulator-5556 --driver=test_driver/integration_test.dart \
///     --target=integration_test/work_smoke_e2e_test.dart \
///     --dart-define-from-file=secrets.json --dart-define=E2E_PHONE=0945958947
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phone = String.fromEnvironment('E2E_PHONE');

  testWidgets('tour', (tester) async {
    final e = E2E(binding, tester)..startLogging();
    try {
      await e.launchAndSignIn(phone);
      await e.waitFor(find.byKey(const ValueKey('jobs-history')));
      await e.settle(const Duration(seconds: 3));
      await e.shot('s1-requests');

      await e.tap(find.byKey(const ValueKey('jobs-history')));
      await e.waitFor(find.byKey(const ValueKey('booking-BK-VLPE6F')));
      await e.shot('s2-history');
      await e.tap(find.byKey(const ValueKey('booking-BK-VLPE6F')));
      await e.waitFor(find.byKey(const ValueKey('booking-landmark')));
      await e.settle(const Duration(seconds: 2));
      await e.shot('s3-expired-detail');
      await e.back();

      await e.tap(find.byKey(const ValueKey('tab-work')));
      await e.waitFor(find.byKey(const ValueKey('offering-CLEANING')));
      await e.shot('s4-work');
      e.log('services listed');

      await e.tap(find.byKey(const ValueKey('add-offering')));
      await e.waitFor(find.byKey(const ValueKey('service-COOKING')));
      await e.tap(find.byKey(const ValueKey('service-COOKING')));
      await e.waitFor(find.byKey(const ValueKey('price-range')));
      e.log('range before typing: ${e.textOf('price-range')}');
      await e.shot('s5-range-hourly');
      await e.tap(find.byKey(const ValueKey('pricing-FIXED')));
      await e.settle();
      e.log('range for FIXED: ${e.textOf('price-range')}');
      await tester.enterText(find.byKey(const ValueKey('offering-amount')), '999');
      await tester.pump();
      await e.tap(find.byKey(const ValueKey('offering-save')));
      await e.settle();
      await e.shot('s6-out-of-range-blocked');
      await e.back();

      await e.tap(find.byKey(const ValueKey('offering-CLEANING')));
      await e.waitFor(find.byKey(const ValueKey('price-range')));
      await e.shot('s7-edit-offering');
      await e.back();

      await e.tap(find.byKey(const ValueKey('open-schedule')));
      await e.waitFor(find.byKey(const ValueKey('schedule-timezone')));
      e.log('schedule: ${e.textOf('schedule-timezone')}');
      await e.shot('s8-schedule');
      await e.back();

      await e.tap(find.byKey(const ValueKey('tab-wallet')));
      await e.waitFor(find.byKey(const ValueKey('wallet-balance')));
      e.log('wallet: ${e.textOf('wallet-balance')} — ${e.textOf('wallet-room')}');
      await e.shot('s9-wallet');
    } finally {
      e.stopLogging();
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}
