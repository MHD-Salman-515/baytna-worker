import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/offering_validator.dart';
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart';
import 'package:baytna_worker/features/offerings/presentation/bloc/offering_form/offering_form_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements OfferingRepository;

class _Countries extends Mock implements CountryRepository;

const _cleaning = Service(
  id: 'cleaning',
  key: 'CLEANING',
  name: LocalizedText(ar: 'تنظيف', en: 'Cleaning'),
  allowedPricingTypes: [PricingType.hourly, PricingType.bySize],
);
const _cooking = Service(
  id: 'cooking',
  key: 'COOKING',
  name: LocalizedText(ar: 'طبخ', en: 'Cooking'),
  allowedPricingTypes: [PricingType.hourly, PricingType.fixed],
);
const _rule = PricingRule(serviceId: 'cooking', pricingType: PricingType.fixed, minPrice: 10000, maxPrice: 50000);
const _existing = Offering(
  id: 'o1',
  serviceId: 'cleaning',
  price: HourlyPrice(rate: 6000, minHours: 2),
  currency: 'SYP',
  isActive: true,
);
const _iraq = Country(id: 'c', code: 'IQ', name: LocalizedText(ar: '', en: ''), phonePrefix: '+964', currencyCode: 'IQD', timezone: 'Asia/Baghdad');

Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  late _Repo repo;
  late _Countries countries;

  setUpAll(() => registerFallbackValue(const FixedPrice(0)));

  setUp(() {
    repo = _Repo();
    countries = _Countries();
    when(() => repo.getServices()).thenAnswer((_) async => const Ok([_cleaning, _cooking]));
    when(() => repo.getPricingRules(any())).thenAnswer((_) async => const Ok([_rule]));
    when(() => repo.getOfferings()).thenAnswer((_) async => const Ok([_existing]));
    when(() => countries.getById(any())).thenAnswer((_) async => const Ok(_iraq));
  });

  Future<OfferingFormBloc> start([String? id]) async {
    final bloc = OfferingFormBloc(repo, countries, 'c', id)..add(const OfferingFormStarted());
    await pump();
    return bloc;
  }

  test('adding offers only services she lacks, and her country currency', () async {
    final bloc = await start();
    expect(bloc.state.selectable, [_cooking]);
    expect(bloc.state.currency, 'IQD');
    await bloc.close();
  });

  test('only allowed pricing types; the range is known before she types', () async {
    final bloc = await start();
    bloc
      ..add(const OfferingServiceSelected('cooking'))
      ..add(const OfferingPricingTypeSelected(PricingType.fixed));
    await pump();
    expect(bloc.state.allowedTypes, [PricingType.hourly, PricingType.fixed]);
    expect(bloc.state.rule, _rule);
    expect(bloc.state.amount, isEmpty);
    await bloc.close();
  });

  test('a price outside the range never reaches the server', () async {
    final bloc = await start();
    bloc
      ..add(const OfferingServiceSelected('cooking'))
      ..add(const OfferingPricingTypeSelected(PricingType.fixed))
      ..add(const OfferingAmountChanged('9999'))
      ..add(const OfferingFormSubmitted());
    await pump();
    expect(bloc.state.status, const FormInvalid({OfferingError.priceOutOfRange}));
    verifyNever(() => repo.create(serviceId: any(named: 'serviceId'), price: any(named: 'price')));
    await bloc.close();
  });

  test('Arabic-Indic digits are parsed; a valid price is created', () async {
    when(() => repo.create(serviceId: any(named: 'serviceId'), price: any(named: 'price'))).thenAnswer((_) async => const Ok(_existing));
    final bloc = await start();
    bloc
      ..add(const OfferingServiceSelected('cooking'))
      ..add(const OfferingPricingTypeSelected(PricingType.fixed))
      ..add(const OfferingAmountChanged('١٥٠٠٠'))
      ..add(const OfferingFormSubmitted());
    await pump();
    expect(bloc.state.status, const FormDone());
    verify(() => repo.create(serviceId: 'cooking', price: const FixedPrice(15000))).called(1);
    await bloc.close();
  });

  test('editing prefills from her offering and keeps its currency', () async {
    final bloc = await start('o1');
    expect(bloc.state.pricingType, PricingType.hourly);
    expect(bloc.state.amount, '6000');
    expect(bloc.state.minHours, '2');
    expect(bloc.state.currency, 'SYP');
    await bloc.close();
  });
}
