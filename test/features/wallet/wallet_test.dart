import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:baytna_worker/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_harness.dart';
import '../../helpers/fake_backend.dart';

void main() {
  const policy = WalletPolicy.defaults;
  WalletStanding at(int balance) => WalletStanding(balance: balance, policy: policy);

  test('zero and small negatives are healthy: a negative balance is normal', () {
    expect(at(1000).health, WalletHealth.healthy);
    expect(at(0).health, WalletHealth.healthy);
    expect(at(-1800).health, WalletHealth.healthy);
  });

  test('warning is AT the threshold, not just below', () {
    expect(at(-1999).health, WalletHealth.healthy);
    expect(at(-2000).health, WalletHealth.low);
  });

  test('exactly on the floor is not past it', () {
    expect(at(-5000).health, WalletHealth.low);
    expect(at(-5001).health, WalletHealth.belowFloor);
  });

  test('room to the floor counts what she can still be charged', () {
    expect(at(0).roomToFloor, 5000);
    expect(at(-1800).roomToFloor, 3200);
    expect(at(-5000).roomToFloor, 0);
    expect(at(-6000).roomToFloor, -1000);
    expect(at(3000).roomToFloor, 8000);
  });

  test('the meter stays in range', () {
    expect(at(0).meter, 1);
    expect(at(9000).meter, 1);
    expect(at(-2500).meter, 0.5);
    expect(at(-9000).meter, 0);
  });

  test('a missing policy block falls back to the documented defaults', () {
    expect(WalletPolicy.fromJson(null), WalletPolicy.defaults);
    expect(WalletPolicy.fromJson(const {'negativeBalanceFloor': -9000}).negativeBalanceFloor, -9000);
  });

  group('through the pipeline', () {
    late ApiHarness h;

    setUp(() {
      h = ApiHarness({
        'GET /api/v1/workers/me/wallet': (_, _) async => FakeBackend.ok({'_id': 'x', 'balance': -1800, 'currency': 'SYP'}),
        'GET /api/v1/workers/me/wallet/entries': (_, _) async => (
          200,
          {
            'success': true,
            'data': [
              {'_id': 'e1', 'type': 'COMMISSION_CHARGE', 'amount': -1800, 'balanceAfter': -1800, 'currency': 'SYP', 'bookingId': 'b1', 'createdAt': '2026-11-01T10:00:00.000Z'},
              {'_id': 'e2', 'type': 'TOPUP', 'amount': 5000, 'balanceAfter': 0, 'currency': 'SYP', 'createdAt': '2026-10-30T10:00:00.000Z'},
            ],
            'meta': {'page': 1, 'limit': 20, 'total': 25, 'totalPages': 2},
          },
        ),
      }, tokens: AuthTokens(accessToken: testJwt(roles: ['WORKER']), refreshToken: 'r'));
    });

    WalletRepositoryImpl repo() => WalletRepositoryImpl(WalletRemoteDataSource(h.api));

    test('a negative balance decodes as an integer', () async {
      expect((await repo().getWallet() as Ok<Wallet>).value, const Wallet(balance: -1800, currency: 'SYP'));
    });

    test('the ledger keeps its paging', () async {
      final page = (await repo().entries() as Ok<Paged<WalletEntry>>).value;
      expect(page.items.first.type, WalletEntryType.commissionCharge);
      expect(page.items.first.balanceAfter, -1800);
      expect(page.meta.hasNext, isTrue);
    });

    test('the commission of a booking is found by booking id', () async {
      expect((await repo().commissionFor('b1') as Ok<WalletEntry?>).value?.id, 'e1');
      expect((await repo().commissionFor('nope') as Ok<WalletEntry?>).value, isNull);
    });
  });
}
