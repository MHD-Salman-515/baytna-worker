import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:baytna_worker/core/dev/dev_otp.dart';
import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:baytna_worker/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Full worker onboarding against the LIVE staging backend, through the real
/// UI on a device: sign in with a NEW number → apply → profile → upload the
/// three documents → submit → status screen shows PENDING_REVIEW.
///
///   flutter drive -d emulator-5556 \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/onboarding_e2e_test.dart \
///     --dart-define-from-file=secrets.json
///
/// A fresh random Syrian number is used unless --dart-define=E2E_PHONE=09…
///
/// The ONLY substitution: the system camera/gallery/file pickers can't be
/// driven from a test, so [DocumentPicker] returns generated images and a
/// PDF. Validation, blocs, upload, network and backend are all real.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phoneOverride = String.fromEnvironment('E2E_PHONE');
  final phone = phoneOverride.isNotEmpty
      ? phoneOverride
      : '0945${Random().nextInt(1000000).toString().padLeft(6, '0')}';

  Future<void> waitFor(WidgetTester tester, Finder finder, {int seconds = 120}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out after ${seconds}s waiting for $finder');
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot(name);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder);
    await tester.pump();
  }

  void log(String message) => debugPrint('[e2e] $message');

  testWidgets('live worker onboarding end-to-end', (tester) async {
    expect(DevOtp.enabled, isTrue, reason: 'Run with --dart-define-from-file=secrets.json');
    final started = DateTime.now();

    final captured = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      final t = DateTime.now().difference(started).inMilliseconds / 1000;
      if (message != null) captured.add('${t.toStringAsFixed(1).padLeft(6)}s  $message');
      originalDebugPrint(message, wrapWidth: wrapWidth);
    };

    try {
      final picker = _GeneratedDocumentPicker(
        front: (await tester.runAsync(() => _idCard('NATIONAL ID — FRONT', const Color(0xFF0F766E))))!,
        back: (await tester.runAsync(() => _idCard('NATIONAL ID — BACK', const Color(0xFF7C3AED))))!,
      );

      await app.main();
      // Swap only the platform picker (see the doc comment above).
      getIt
        ..unregister<DocumentPicker>()
        ..registerSingleton<DocumentPicker>(picker);
      if (defaultTargetPlatform == TargetPlatform.android) await binding.convertFlutterSurfaceToImage();
      log('phone under test: $phone (new account)');

      // 1 — sign in with phone + OTP.
      await waitFor(tester, find.byKey(const ValueKey('country-SY')));
      await tester.pump(const Duration(seconds: 1));
      await shot(tester, '01-country');
      await tester.tap(find.byKey(const ValueKey('country-SY')));
      await waitFor(tester, find.byKey(const ValueKey('phone-field')));
      await tester.enterText(find.byKey(const ValueKey('phone-field')), phone);
      await tester.pump();
      await shot(tester, '02-phone');
      await tester.tap(find.byKey(const ValueKey('send-code')));
      await waitFor(tester, find.byKey(const ValueKey('otp-field')), seconds: 90);
      await shot(tester, '03-otp');
      await tester.tap(find.byKey(const ValueKey('dev-otp-fill')));
      log('OTP via dev helper; six digits auto-submit');

      // 2 — a brand-new account is CUSTOMER only → the apply screen.
      await waitFor(tester, find.byKey(const ValueKey('apply')), seconds: 90);
      await shot(tester, '04-apply');
      if (getIt<AuthBloc>().state case AuthAuthenticated(:final user)) {
        log('signed in: user ${user.id}, roles ${user.roles}, created ${user.createdAt?.toIso8601String()}');
      }
      log('→ apply screen (no WORKER role yet)');
      await tester.tap(find.byKey(const ValueKey('apply')));

      // 3 — applied + token refreshed → status screen in DRAFT.
      await waitFor(tester, find.byKey(const ValueKey('status-DRAFT')), seconds: 90);
      await shot(tester, '05-status-draft');
      log('applied; status DRAFT');

      // 4 — profile.
      await tester.tap(find.byKey(const ValueKey('step-profile')));
      await waitFor(tester, find.byKey(const ValueKey('profile-bio-ar')), seconds: 60);
      await tester.enterText(find.byKey(const ValueKey('profile-bio-ar')), 'خبرة خمس سنوات في تنظيف المنازل والطبخ والكي.');
      await tester.enterText(find.byKey(const ValueKey('profile-bio-en')), 'Five years of home cleaning, cooking and ironing.');
      await tester.enterText(find.byKey(const ValueKey('profile-years')), '5');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 500));
      await tapVisible(tester, find.byKey(const ValueKey('lang-ar')));
      await tapVisible(tester, find.byKey(const ValueKey('lang-ku')));
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'دمشق'));
      await tapVisible(tester, find.widgetWithText(FilterChip, 'حلب'));
      await shot(tester, '06-profile');
      await tapVisible(tester, find.byKey(const ValueKey('profile-save')));
      log('profile saved: Damascus, areas Damascus + Aleppo, ar + ku, 5 years');

      // 5 — documents (the first save continues straight here).
      await waitFor(tester, find.byKey(const ValueKey('doc-NATIONAL_ID_FRONT')), seconds: 60);
      await tester.pump(const Duration(seconds: 1));
      await shot(tester, '07-documents-empty');

      Future<void> uploadDoc(String type, String source, String shotName, {bool expiry = false}) async {
        await tapVisible(tester, find.byKey(ValueKey('pick-$type-$source')));
        await waitFor(tester, find.byKey(ValueKey('upload-$type')), seconds: 10);
        if (expiry) {
          await tapVisible(tester, find.byKey(ValueKey('expiry-$type')));
          await waitFor(tester, find.byType(DatePickerDialog), seconds: 10);
          final ok = MaterialLocalizations.of(tester.element(find.byType(DatePickerDialog))).okButtonLabel;
          await tester.tap(find.text(ok));
          await tester.pump(const Duration(milliseconds: 500));
        }
        await tester.ensureVisible(find.byKey(ValueKey('upload-$type')));
        await shot(tester, '$shotName-preview');
        await tester.tap(find.byKey(ValueKey('upload-$type')));
        // Uploaded = the draft (and its upload button) is gone.
        final end = DateTime.now().add(const Duration(seconds: 120));
        while (find.byKey(ValueKey('upload-$type')).evaluate().isNotEmpty) {
          if (DateTime.now().isAfter(end)) throw TestFailure('upload of $type did not finish');
          await tester.pump(const Duration(milliseconds: 250));
        }
        await tester.pump(const Duration(seconds: 1));
        await tester.ensureVisible(find.byKey(ValueKey('doc-$type')));
        await shot(tester, '$shotName-uploaded');
        log('uploaded $type (picked via "$source")');
      }

      await uploadDoc('NATIONAL_ID_FRONT', 'camera', '08-front');
      await uploadDoc('NATIONAL_ID_BACK', 'gallery', '09-back');
      await uploadDoc('CRIMINAL_RECORD', 'file', '10-criminal', expiry: true);

      // 6 — back to the status screen and submit.
      // The "uploaded" snackbar floats over the bottom button; a real user
      // waits for it, the test dismisses it.
      ScaffoldMessenger.of(tester.element(find.byKey(const ValueKey('documents-done')))).clearSnackBars();
      await tester.pump(const Duration(milliseconds: 500));
      await tapVisible(tester, find.byKey(const ValueKey('documents-done')));
      await waitFor(tester, find.byKey(const ValueKey('submit')), seconds: 30);
      await tester.pump(const Duration(seconds: 3)); // documents list reloads
      await shot(tester, '11-status-ready');
      await tapVisible(tester, find.byKey(const ValueKey('submit')));

      await waitFor(tester, find.byKey(const ValueKey('status-PENDING_REVIEW')), seconds: 90);
      await tester.pump(const Duration(seconds: 3));
      await shot(tester, '12-status-pending-review');
      final waiting = tester.widget<Text>(find.byKey(const ValueKey('waiting-for'))).data;
      log('STATUS: PENDING_REVIEW — "$waiting"');
      log('total ${DateTime.now().difference(started).inSeconds}s; phone $phone');
    } finally {
      debugPrint = originalDebugPrint;
      (binding.reportData ??= <String, dynamic>{})['log'] = captured;
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}

/// Stands in for the system pickers: camera → ID front, gallery → ID back,
/// file → a criminal-record PDF.
class _GeneratedDocumentPicker implements DocumentPicker {
  _GeneratedDocumentPicker({required this.front, required this.back});

  final Uint8List front;
  final Uint8List back;

  @override
  Future<PickedBytes?> pick(DocumentSource source) async => switch (source) {
    DocumentSource.camera => PickedBytes(bytes: front, name: 'IMG_0001.png'),
    DocumentSource.gallery => PickedBytes(bytes: back, name: 'IMG_0002.png'),
    DocumentSource.file => PickedBytes(bytes: _pdf(), name: 'criminal-record.pdf'),
  };
}

/// A clearly fake "ID card" PNG, so nothing resembling a real ID is uploaded.
Future<Uint8List> _idCard(String label, Color color) async {
  const w = 856.0;
  const h = 540.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFF1F5F9))
    ..drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(24, 24, w - 48, h - 48), const Radius.circular(28)),
      Paint()..color = color,
    )
    ..drawCircle(const Offset(190, 270), 96, Paint()..color = const Color(0x66FFFFFF));
  for (var i = 0; i < 4; i++) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(340, 170.0 + i * 56, 420 - i * 60, 26), const Radius.circular(8)),
      Paint()..color = const Color(0x99FFFFFF),
    );
  }
  final paragraph = (ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 40, fontWeight: FontWeight.w800))
        ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF)))
        ..addText('SAMPLE — $label'))
      .build()
    ..layout(const ui.ParagraphConstraints(width: w - 120));
  canvas.drawParagraph(paragraph, const Offset(60, 60));
  final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Uint8List _pdf() => Uint8List.fromList(
  utf8.encode(
    '%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n'
    '2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n'
    '3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 595 842]>>endobj\n'
    'trailer<</Root 1 0 R>>\n%%EOF\n',
  ),
);
