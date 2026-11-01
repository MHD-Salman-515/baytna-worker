import 'package:baytna_worker/features/bookings/presentation/widgets/swipe_to_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<int Function()> pump(WidgetTester tester, TextDirection direction, {bool enabled = true}) async {
    var confirmed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: SwipeToConfirm(label: 'x', enabled: enabled, onConfirmed: () => confirmed++),
              ),
            ),
          ),
        ),
      ),
    );
    return () => confirmed;
  }

  final thumb = find.byIcon(Icons.arrow_forward_rounded);

  testWidgets("a tap does nothing: completing can't be an accident", (tester) async {
    final count = await pump(tester, TextDirection.rtl);
    await tester.tap(thumb);
    await tester.tap(find.byType(SwipeToConfirm));
    await tester.pumpAndSettle();
    expect(count(), 0);
  });

  testWidgets('RTL: dragging leftwards to the end confirms, once', (tester) async {
    final count = await pump(tester, TextDirection.rtl);
    await tester.drag(thumb, const Offset(-290, 0));
    await tester.pumpAndSettle();
    expect(count(), 1);
  });

  testWidgets('RTL: dragging the wrong way does nothing', (tester) async {
    final count = await pump(tester, TextDirection.rtl);
    await tester.drag(thumb, const Offset(290, 0));
    await tester.pumpAndSettle();
    expect(count(), 0);
  });

  testWidgets('LTR mirrors it', (tester) async {
    final count = await pump(tester, TextDirection.ltr);
    await tester.drag(thumb, const Offset(290, 0));
    await tester.pumpAndSettle();
    expect(count(), 1);
  });

  testWidgets('letting go early springs back without confirming', (tester) async {
    final count = await pump(tester, TextDirection.rtl);
    final start = tester.getCenter(thumb);
    await tester.drag(thumb, const Offset(-150, 0));
    await tester.pumpAndSettle();
    expect(count(), 0);
    expect(tester.getCenter(thumb), start);
  });

  testWidgets('disabled while the request runs', (tester) async {
    final count = await pump(tester, TextDirection.rtl, enabled: false);
    await tester.drag(thumb, const Offset(-290, 0));
    await tester.pumpAndSettle();
    expect(count(), 0);
  });
}
