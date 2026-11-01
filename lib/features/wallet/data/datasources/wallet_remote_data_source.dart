import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WalletRemoteDataSource {
  WalletRemoteDataSource(this._api);

  final ApiClient _api;

  /// `{ _id, workerProfileId, countryId, balance, currency, … }`.
  Future<Wallet> wallet() => _api.get(
    '/workers/me/wallet',
    decode: (data) {
      final json = asJson(data);
      return Wallet(balance: moneyFromJson(json['balance']), currency: json['currency'] as String);
    },
  );

  Future<Paged<WalletEntry>> entries({int page = 1, int limit = 20}) => _api.getPage(
    '/workers/me/wallet/entries',
    query: {'page': page, 'limit': limit},
    decodeItem: _entry,
  );

  /// ⚠ UNVERIFIED: her ledger is still empty on staging, so these field names
  /// are the expected ones and alternates, not yet observed.
  static WalletEntry _entry(Json json) => WalletEntry(
    id: (json['id'] ?? json['_id']) as String,
    type: WalletEntryType.fromApi(json['type']),
    amount: moneyFromJson(json['amount']),
    currency: json['currency'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    balanceAfter: moneyFromJsonOrNull(json['balanceAfter'] ?? json['runningBalance']),
    bookingId: json['bookingId'] as String?,
    note: (json['note'] ?? json['reason'] ?? json['reference']) as String?,
  );
}
