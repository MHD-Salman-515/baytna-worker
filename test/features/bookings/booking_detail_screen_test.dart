import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/bookings/data/models/booking_model.dart';
import 'package:baytna_worker/features/bookings/domain/booking_context.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/bookings/domain/repositories/booking_repository.dart';
import 'package:baytna_worker/features/bookings/presentation/bloc/booking_detail/booking_detail_bloc.dart';
import 'package:baytna_worker/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/deadline_countdown.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';
import 'package:baytna_worker/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/booking_fixtures.dart';

class _Bookings extends Mock implements BookingRepository;

class _Context extends Mock implements BookingContextLoader;

class _Offerings extends Mock implements OfferingRepository;

class _Wallet extends Mock implements WalletRepository;

class _Worker extends MockBloc<WorkerEvent, WorkerState> implements WorkerBloc;

class _Fixed extends Clock {
  const _Fixed();

  @override
  DateTime now() => DateTime.utc(2026, 11, 1, 12);
}

const _syria = Country(id: 'sy', code: 'SY', name: LocalizedText(ar: '', en: ''), phonePrefix: '+963', currencyCode: 'SYP', timezone: 'Asia/Damascus');
const _offering = Offering(id: 'ws1', serviceId: 's1', price: HourlyPrice(rate: 6000, minHours: 2), currency: 'SYP', isActive: true);

WorkerProfile _profile({FinancialStatus financial = FinancialStatus.active}) => WorkerProfile(
  id: 'w1',
  countryId: 'sy',
  cityId: 'damascus',
  verificationStatus: VerificationStatus.approved,
  financialStatus: financial,
  isAvailable: true,
);

void main() {
  late _Bookings bookings;
  late _Worker worker;
  late _Wallet wallet;

  setUp(() async {
    await getIt.reset();
    bookings = _Bookings();
    worker = _Worker();
    wallet = _Wallet();
    final context = _Context();
    final offerings = _Offerings();
    when(() => context.load(any())).thenAnswer((_) async => Ok(BookingContext(country: _syria, cities: const [], services: const [])));
    when(offerings.getOfferings).thenAnswer((_) async => const Ok([_offering]));
    when(() => wallet.commissionFor(any())).thenAnswer((_) async => const Ok(null));
    getIt
      ..registerSingleton<Clock>(const _Fixed())
      ..registerFactoryParam<BookingDetailBloc, String, String>(
        (id, countryId) => BookingDetailBloc(bookings, context, offerings, wallet, id, countryId),
      );
  });

  Future<void> show(WidgetTester tester, Booking booking, WorkerProfile profile) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    when(() => bookings.find(any(), expectedStatus: any(named: 'expectedStatus'))).thenAnswer((_) async => Ok(booking));
    whenListen(worker, const Stream<WorkerState>.empty(), initialState: WorkerLoaded(profile));
    await tester.pumpWidget(
      BlocProvider<WorkerBloc>.value(
        value: worker,
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BookingDetailScreen(bookingId: 'b1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
  }

  Booking booking(String status, [Map<String, dynamic> overrides = const {}]) =>
      BookingMapper.fromJson(bookingJson(status: status, overrides: overrides));

  FilledButton accept(WidgetTester tester) => tester.widget<FilledButton>(
    find.descendant(of: find.byKey(const ValueKey('accept-booking')), matching: find.byType(FilledButton)),
  );

  testWidgets('deciding: landmark prominent, hidden fields stated, countdown running', (tester) async {
    await show(tester, booking('PENDING_WORKER'), _profile());
    expect(find.text('مقابل صيدلية الشفاء'), findsOneWidget);
    expect(find.byKey(const ValueKey('booking-hidden-note')), findsOneWidget);
    expect(find.byKey(const ValueKey('call-customer')), findsNothing);
    expect(find.byKey(const ValueKey('deadline-countdown')), findsOneWidget);
    expect(find.textContaining('33:36:01'), findsOneWidget);
    expect(find.textContaining('15,300'), findsOneWidget);
    expect(accept(tester).onPressed, isNotNull);
  });

  testWidgets('financially suspended: can NOT accept, can still reject', (tester) async {
    await show(tester, booking('PENDING_WORKER'), _profile(financial: FinancialStatus.suspended));
    expect(accept(tester).onPressed, isNull);
    expect(find.byKey(const ValueKey('accept-blocked')), findsOneWidget);
    expect(tester.widget<OutlinedButton>(find.byKey(const ValueKey('reject-booking'))).onPressed, isNotNull);
  });

  group('financially suspended: CAN finish a job in hand', () {
    final suspended = _profile(financial: FinancialStatus.suspended);

    for (final (status, key) in [('ACCEPTED', 'step-on-the-way'), ('ON_THE_WAY', 'step-arrived'), ('ARRIVED', 'step-start')]) {
      testWidgets(status, (tester) async {
        await show(tester, booking(status), suspended);
        final button = find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(FilledButton));
        expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      });
    }

    testWidgets('IN_PROGRESS: the swipe is there', (tester) async {
      await show(tester, booking('IN_PROGRESS', {'startedAt': '2026-11-01T11:00:00.000Z'}), suspended);
      expect(find.byKey(const ValueKey('swipe-complete')), findsOneWidget);
      expect(find.byKey(const ValueKey('accept-blocked')), findsNothing);
    });
  });

  group('verification suspended mid-job: CAN finish, exactly as with money', () {
    const suspended = WorkerProfile(
      id: 'w1',
      countryId: 'sy',
      cityId: 'damascus',
      verificationStatus: VerificationStatus.suspended,
      financialStatus: FinancialStatus.active,
    );

    for (final (status, key) in [('ACCEPTED', 'step-on-the-way'), ('ON_THE_WAY', 'step-arrived'), ('ARRIVED', 'step-start')]) {
      testWidgets(status, (tester) async {
        await show(tester, booking(status), suspended);
        final button = find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(FilledButton));
        expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      });
    }

    testWidgets('IN_PROGRESS: the swipe is there', (tester) async {
      await show(tester, booking('IN_PROGRESS', {'startedAt': '2026-11-01T11:00:00.000Z'}), suspended);
      expect(find.byKey(const ValueKey('swipe-complete')), findsOneWidget);
    });

    testWidgets('COMPLETED: no way into the closed wallet tab', (tester) async {
      await show(tester, booking('COMPLETED', {'startedAt': '2026-11-01T11:00:00.000Z', 'completedAt': '2026-11-01T13:00:00.000Z'}), suspended);
      expect(find.byKey(const ValueKey('final-earnings')), findsOneWidget);
      expect(find.byKey(const ValueKey('see-wallet')), findsNothing);
    });

    testWidgets("a NEW request still can't be accepted", (tester) async {
      await show(tester, booking('PENDING_WORKER'), suspended);
      expect(accept(tester).onPressed, isNull);
    });
  });

  testWidgets('city only before accepting: nothing that reads like a distance', (tester) async {
    await show(tester, booking('PENDING_WORKER'), _profile());
    expect(find.textContaining('km'), findsNothing);
  });

  testWidgets('deadline already past: no accepting into a 400', (tester) async {
    await show(tester, booking('PENDING_WORKER', {'responseDeadline': '2026-11-01T11:59:00.000Z'}), _profile());
    expect(find.byKey(const ValueKey('accept-booking')), findsNothing);
  });

  testWidgets('in progress: estimate labelled, no cancel (the server refuses it)', (tester) async {
    await show(tester, booking('IN_PROGRESS', {'startedAt': '2026-11-01T11:00:00.000Z'}), _profile());
    expect(find.byKey(const ValueKey('estimated-earnings')), findsOneWidget);
    expect(find.byKey(const ValueKey('elapsed-timer')), findsOneWidget);
    expect(find.textContaining('estimate for 3 hours'), findsOneWidget);
    expect(find.byKey(const ValueKey('cancel-booking')), findsNothing);
  });

  testWidgets('completed under the minimum: final vs estimate, and why', (tester) async {
    when(() => wallet.commissionFor(any())).thenAnswer(
      (_) async => Ok(
        WalletEntry(id: 'e', type: WalletEntryType.commissionCharge, amount: -1800, currency: 'SYP', createdAt: DateTime.utc(2026), balanceAfter: -1800),
      ),
    );
    await show(
      tester,
      booking('COMPLETED', {
        'startedAt': '2026-11-01T11:00:00.000Z',
        'completedAt': '2026-11-01T11:20:00.000Z',
        'finalPricing': {'pricingType': 'HOURLY', 'hours': 2, 'workerEarnings': 10200, 'currency': 'SYP'},
      }),
      _profile(),
    );
    await tester.pump(const Duration(milliseconds: 10));
    String text(String key) => tester.widget<Text>(find.byKey(ValueKey(key))).data!;
    expect(text('final-earnings'), contains('10,200'));
    expect(text('estimate-was'), contains('15,300'));
    expect(text('commission-charged'), contains('1,800'));
    expect(find.textContaining('your minimum (2 hours)'), findsOneWidget);
    expect(find.byKey(const ValueKey('swipe-complete')), findsNothing);
  });

  test('countdown format is H:MM:SS, may exceed a day, never negative', () {
    expect(formatCountdown(const Duration(hours: 33, minutes: 5, seconds: 9)), '\u206633:05:09\u2069');
    expect(formatCountdown(const Duration(seconds: -5)), '\u20660:00:00\u2069');
  });
}
