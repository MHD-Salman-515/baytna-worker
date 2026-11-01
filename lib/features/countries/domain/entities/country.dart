import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// A market the app operates in. The backend also sends booking, instant
/// matching and review policies; they're added here when a feature needs them.
class Country extends Equatable {
  const Country({
    required this.id,
    required this.code,
    required this.name,
    required this.phonePrefix,
    required this.currencyCode,
    required this.timezone,
    this.walletPolicy = WalletPolicy.defaults,
  });

  final String id;

  /// ISO 3166-1 alpha-2, e.g. "SY".
  final String code;
  final LocalizedText name;

  /// With the plus sign, e.g. "+963".
  final String phonePrefix;
  final String currencyCode;

  /// IANA zone, e.g. "Asia/Damascus". Her availability windows and every
  /// booking time are read in this zone, never the phone's.
  final String timezone;
  final WalletPolicy walletPolicy;

  /// Regional-indicator flag emoji derived from [code].
  String get flag => String.fromCharCodes(
    code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41),
  );

  @override
  List<Object?> get props => [id, code, name, phonePrefix, currencyCode, timezone, walletPolicy];
}

/// The country's `walletPolicy` block. GET /workers/me/wallet carries neither
/// the floor nor the warning level, so they come from here. Data-driven per
/// country: never hard-code these numbers in a screen.
class WalletPolicy extends Equatable {
  const WalletPolicy({
    required this.negativeBalanceFloor,
    required this.lowBalanceWarningThreshold,
    required this.workerCancellationPenaltyAmount,
  });

  /// Tolerates a missing block by falling back to the backend's documented
  /// defaults (Swagger: CountryWalletPolicyDto).
  factory WalletPolicy.fromJson(Object? json) {
    final m = json is Map ? json : const <String, Object?>{};
    int read(String key, int fallback) => moneyFromJsonOrNull(m[key]) ?? fallback;
    return WalletPolicy(
      negativeBalanceFloor: read('negativeBalanceFloor', defaults.negativeBalanceFloor),
      lowBalanceWarningThreshold: read('lowBalanceWarningThreshold', defaults.lowBalanceWarningThreshold),
      workerCancellationPenaltyAmount: read('workerCancellationPenaltyAmount', defaults.workerCancellationPenaltyAmount),
    );
  }

  static const defaults = WalletPolicy(
    negativeBalanceFloor: -5000,
    lowBalanceWarningThreshold: -2000,
    workerCancellationPenaltyAmount: 0,
  );

  /// Signed. Below this she is financially suspended automatically.
  final int negativeBalanceFloor;

  /// Signed. At or below this she gets a low-balance warning.
  final int lowBalanceWarningThreshold;

  /// Charged to her wallet when she cancels after accepting.
  final int workerCancellationPenaltyAmount;

  @override
  List<Object?> get props => [negativeBalanceFloor, lowBalanceWarningThreshold, workerCancellationPenaltyAmount];
}
