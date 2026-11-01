import 'package:baytna_worker/features/bookings/presentation/widgets/swipe_to_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support.dart';

/// A FULL real job against LIVE staging, through the real UI. This MOVES REAL
/// STATE: it accepts a pending booking, completes it, and charges commission.
/// It needs a PENDING_WORKER booking and fails plainly if there is none.
///
///   flutter drive -d emulator-5556 --driver=test_driver/integration_test.dart \
///     --target=integration_test/job_e2e_test.dart \
///     --dart-define-from-file=secrets.json --dart-define=E2E_PHONE=0945958947
///
/// --dart-define=E2E_WORK_SECONDS=8100 stays "working" that long before
/// completing, so the final price comes from real elapsed time rather than
/// the minimum (2 h 15 min at 6,000/h is what crosses the warning level).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phone = String.fromEnvironment('E2E_PHONE');
  final workSeconds = const int.fromEnvironment('E2E_WORK_SECONDS');

  testWidgets('full job', (tester) async {
    final e = E2E(binding, tester)..startLogging();
    Finder key(String k) => find.byKey(ValueKey(k));
    try {
      await e.launchAndSignIn(phone);
      await e.waitFor(key('jobs-requests'));
      await e.settle(const Duration(seconds: 4));
      await e.shot('j01-requests');

      final cards = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('booking-BK-'));
      expect(cards, findsWidgets, reason: 'No PENDING_WORKER booking: create one from the customer app first.');
      await tester.tap(cards.first);
      await e.waitFor(key('accept-booking'));
      await e.settle(const Duration(seconds: 2));
      e.log('DECISION landmark: ${e.textOf('booking-landmark')}');
      e.log('DECISION place: ${e.textOf('booking-place')}');
      e.log('DECISION hidden until accepted: ${key('booking-address').evaluate().isEmpty}');
      e.log('ESTIMATE ${e.textOf('estimated-earnings')} — ${e.textOf('estimate-basis')}');
      await e.shot('j02-decision');

      await e.tap(key('accept-booking'));
      await e.waitFor(key('step-on-the-way'), seconds: 60);
      await e.settle(const Duration(seconds: 2));
      e.log('ACCEPTED address revealed: ${key('booking-address').evaluate().isNotEmpty}, phone: ${key('call-customer').evaluate().isNotEmpty}');
      await e.shot('j03-accepted-revealed');

      await e.tap(key('step-on-the-way'));
      await e.waitFor(key('step-arrived'), seconds: 60);
      await e.shot('j04-on-the-way');

      await e.tap(key('step-arrived'));
      await e.waitFor(key('step-start'), seconds: 60);
      await e.shot('j05-arrived');

      await e.tap(key('step-start'));
      await e.waitFor(key('swipe-complete'), seconds: 60);
      await e.settle(const Duration(seconds: 2));
      await e.shot('j06-in-progress');
      e.log('IN PROGRESS, estimate still ${e.textOf('estimated-earnings')}');

      if (workSeconds > 0) {
        e.log('working for ${workSeconds}s of real time');
        await e.settle(Duration(seconds: workSeconds));
      }

      // A tap must do nothing: completing is a swipe.
      await tester.tap(find.byType(SwipeToConfirm));
      await e.settle();
      expect(key('swipe-complete'), findsOneWidget);
      e.log('a tap on the swipe did nothing');

      final thumb = find.descendant(of: key('swipe-complete'), matching: find.byIcon(Icons.arrow_forward_rounded));
      await tester.timedDrag(thumb, const Offset(-900, 0), const Duration(milliseconds: 700));
      await e.waitFor(key('final-earnings'), seconds: 90);
      await e.settle(const Duration(seconds: 5));
      await tester.ensureVisible(key('final-earnings'));
      e.log('FINAL ${e.textOf('final-earnings')} vs ESTIMATE ${e.textOf('estimate-was')}');
      if (key('commission-charged').evaluate().isNotEmpty) e.log('COMMISSION ${e.textOf('commission-charged')}');
      if (key('why-different').evaluate().isNotEmpty) e.log('WHY ${e.textOf('why-different')}');
      await e.shot('j07-completed-money');

      await e.tap(key('see-wallet'));
      await e.waitFor(key('wallet-balance'), seconds: 60);
      await e.settle(const Duration(seconds: 3));
      e.log('WALLET ${e.textOf('wallet-balance')} — ${e.textOf('wallet-room')}');
      if (key('wallet-warning').evaluate().isNotEmpty) e.log('WARNING ${e.textOf('wallet-warning')}');
      expect(key('entry-COMMISSION_CHARGE'), findsOneWidget);
      await e.shot('j08-wallet-ledger');
    } finally {
      e.stopLogging();
    }
  }, timeout: const Timeout(Duration(hours: 4)));
}
