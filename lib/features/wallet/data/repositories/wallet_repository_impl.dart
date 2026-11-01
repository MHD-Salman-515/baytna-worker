import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';
import 'package:baytna_worker/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._remote);

  final WalletRemoteDataSource _remote;

  @override
  Future<Result<Wallet>> getWallet() => guard(_remote.wallet);

  @override
  Future<Result<Paged<WalletEntry>>> entries({int page = 1, int limit = 20}) =>
      guard(() => _remote.entries(page: page, limit: limit));

  @override
  Future<Result<WalletEntry?>> commissionFor(String bookingId) => guard(() async {
    final page = await _remote.entries(limit: 100);
    return page.items
        .where((e) => e.bookingId == bookingId && e.type == WalletEntryType.commissionCharge)
        .firstOrNull;
  });
}
