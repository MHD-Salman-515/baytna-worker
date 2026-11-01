import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:equatable/equatable.dart';

/// GET /workers/me/wallet is only `{ balance, currency }`: floor and warning
/// level are country policy, and suspension is `profile.financialStatus`.
class Wallet extends Equatable {
  const Wallet({required this.balance, required this.currency});

  final int balance;
  final String currency;

  Money get money => Money(balance, currency);

  @override
  List<Object?> get props => [balance, currency];
}

enum WalletEntryType {
  topup('TOPUP'),
  commissionCharge('COMMISSION_CHARGE'),
  cancellationFee('CANCELLATION_FEE'),
  adjustment('ADJUSTMENT'),
  refund('REFUND'),
  reversal('REVERSAL'),
  unknown('');

  WalletEntryType(this.apiValue);

  final String apiValue;

  static WalletEntryType fromApi(Object? value) =>
      values.firstWhere((t) => t.apiValue == value && t != unknown, orElse: () => unknown);
}

/// One line of her ledger, signed: charges are negative.
class WalletEntry extends Equatable {
  const WalletEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.balanceAfter,
    this.bookingId,
  });

  final String id;
  final WalletEntryType type;
  final int amount;
  final String currency;
  final DateTime createdAt;

  /// Running balance after this line.
  final int? balanceAfter;
  final String? bookingId;

  Money get money => Money(amount, currency);

  @override
  List<Object?> get props => [id, type, amount, currency, createdAt, balanceAfter, bookingId];
}

enum WalletHealth {
  healthy,

  /// At or below the country's warning level.
  low,

  /// Below the floor: she is suspended automatically until she tops up.
  belowFloor,
}

/// Where her balance stands relative to the country's limits. A negative
/// balance is normal, so "how far from the floor" is what matters, not the
/// sign.
class WalletStanding extends Equatable {
  const WalletStanding({required this.balance, required this.policy});

  final int balance;
  final WalletPolicy policy;

  /// What she can still be charged before suspension. Negative once past it.
  int get roomToFloor => balance - policy.negativeBalanceFloor;

  WalletHealth get health {
    if (balance < policy.negativeBalanceFloor) return WalletHealth.belowFloor;
    if (balance <= policy.lowBalanceWarningThreshold) return WalletHealth.low;
    return WalletHealth.healthy;
  }

  /// 0 (at or past the floor) .. 1 (zero balance or better), for a meter.
  /// A display ratio only; no money is ever computed from it.
  double get meter {
    final span = -policy.negativeBalanceFloor;
    if (span <= 0) return 1;
    return (roomToFloor / span).clamp(0, 1).toDouble();
  }

  @override
  List<Object?> get props => [balance, policy];
}
