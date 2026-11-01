import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';

abstract interface class WalletRepository {
  Future<Result<Wallet>> getWallet();

  /// Her ledger, newest first.
  Future<Result<Paged<WalletEntry>>> entries({int page = 1, int limit = 20});

  /// The commission line for a booking, if it's on the recent pages.
  Future<Result<WalletEntry?>> commissionFor(String bookingId);
}
