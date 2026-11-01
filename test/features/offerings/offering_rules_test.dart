import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/offerings/data/datasources/offering_remote_data_source.dart';
import 'package:baytna_worker/features/offerings/data/models/offering_models.dart';
import 'package:baytna_worker/features/offerings/data/repositories/offering_repository_impl.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/offering_failures.dart';
import 'package:baytna_worker/features/offerings/domain/offering_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_harness.dart';
import '../../helpers/fake_backend.dart';

const _hourlyRule = PricingRule(serviceId: 's', pricingType: PricingType.hourly, minPrice: 5000, maxPrice: 20000);
const _sizeRule = PricingRule(serviceId: 's', pricingType: PricingType.bySize, minPrice: 10000, maxPrice: 80000);

void main() {
  group('client-side validation', () {
    test('range bounds are inclusive', () {
      expect(OfferingValidator.validate(const HourlyPrice(rate: 5000, minHours: 2), _hourlyRule), isEmpty);
      expect(OfferingValidator.validate(const HourlyPrice(rate: 20000, minHours: 2), _hourlyRule), isEmpty);
      expect(OfferingValidator.validate(const HourlyPrice(rate: 4999, minHours: 2), _hourlyRule), {OfferingError.priceOutOfRange});
      expect(OfferingValidator.validate(const HourlyPrice(rate: 20001, minHours: 2), _hourlyRule), {OfferingError.priceOutOfRange});
    });

    test('minHours at least 1', () {
      expect(OfferingValidator.validate(const HourlyPrice(rate: 6000, minHours: 0), _hourlyRule), {OfferingError.minHoursInvalid});
    });

    test('BY_SIZE: every tier in range, rooms strictly ascending, at least one tier', () {
      const ok = BySizePrice([SizeTier(maxRooms: 2, price: 10000), SizeTier(maxRooms: 4, price: 20000)]);
      expect(OfferingValidator.validate(ok, _sizeRule), isEmpty);
      expect(
        OfferingValidator.validate(const BySizePrice([SizeTier(maxRooms: 2, price: 1)]), _sizeRule),
        {OfferingError.priceOutOfRange},
      );
      expect(
        OfferingValidator.validate(const BySizePrice([SizeTier(maxRooms: 4, price: 10000), SizeTier(maxRooms: 4, price: 20000)]), _sizeRule),
        {OfferingError.tiersNotAscending},
      );
      expect(OfferingValidator.validate(const BySizePrice([]), _sizeRule), {OfferingError.tiersEmpty});
    });

    test('with no rule the server has the last word', () {
      expect(OfferingValidator.validate(const FixedPrice(1), null), isEmpty);
    });
  });

  group('wire format', () {
    test('all three models decode from the staging shape', () {
      Map<String, Object?> json(String type, Map<String, Object?> block) => {
        'id': 'o',
        'serviceId': 's',
        'pricingType': type,
        'hourly': null,
        'bySize': null,
        'fixed': null,
        ...block,
        'currency': 'SYP',
        'isActive': true,
      };
      expect(
        OfferingMapper.offering(json('HOURLY', {'hourly': {'rate': 6000, 'minHours': 2}})).price,
        const HourlyPrice(rate: 6000, minHours: 2),
      );
      expect(OfferingMapper.offering(json('FIXED', {'fixed': {'price': 15000}})).price, const FixedPrice(15000));
      expect(
        OfferingMapper.offering(json('BY_SIZE', {'bySize': {'tiers': [{'maxRooms': 2, 'price': 20000}]}})).price,
        const BySizePrice([SizeTier(maxRooms: 2, price: 20000)]),
      );
    });

    test('the body carries pricingType + its block, and never a currency', () {
      expect(OfferingMapper.priceBody(const HourlyPrice(rate: 6000, minHours: 2)), {
        'pricingType': 'HOURLY',
        'hourly': {'rate': 6000, 'minHours': 2},
      });
      expect(OfferingMapper.priceBody(const FixedPrice(15000)), {
        'pricingType': 'FIXED',
        'fixed': {'price': 15000},
      });
    });
  });

  group('server refusals', () {
    Future<Object> failWith(int status, Object message) async {
      final h = ApiHarness({
        'POST /api/v1/workers/me/services': (_, _) async => FakeBackend.error(status, message),
      }, tokens: AuthTokens(accessToken: testJwt(roles: ['WORKER']), refreshToken: 'r'));
      final r = await OfferingRepositoryImpl(OfferingRemoteDataSource(h.api)).create(serviceId: 's', price: const FixedPrice(1));
      return (r as Err<Offering>).failure;
    }

    test('out of range is parsed, naming the range', () async {
      final f = await failWith(400, 'price must be between 10000 and 50000 (inclusive)');
      expect(f, isA<PriceOutOfRange>().having((e) => e.min, 'min', 10000).having((e) => e.max, 'max', 50000));
    });

    test('pricing type not allowed; duplicate offering', () async {
      expect(await failWith(400, 'BY_SIZE is not an allowed pricing type for COOKING (allowed: HOURLY, FIXED)'), isA<PricingTypeNotAllowed>());
      expect(await failWith(409, 'You already offer this service — update it instead of creating a duplicate'), isA<OfferingAlreadyExists>());
    });
  });
}
