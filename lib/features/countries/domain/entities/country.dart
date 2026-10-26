import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// A market the app operates in. The backend also sends policy blocks
/// (booking, instant matching, wallet, review); they're added here when a
/// feature needs them, not before.
class Country extends Equatable {
  const Country({
    required this.id,
    required this.code,
    required this.name,
    required this.phonePrefix,
    required this.currencyCode,
    required this.timezone,
  });

  final String id;

  /// ISO 3166-1 alpha-2, e.g. "SY".
  final String code;
  final LocalizedText name;

  /// With the plus sign, e.g. "+963".
  final String phonePrefix;
  final String currencyCode;
  final String timezone;

  /// Regional-indicator flag emoji derived from [code].
  String get flag => String.fromCharCodes(
    code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41),
  );

  @override
  List<Object?> get props => [id, code, name, phonePrefix, currencyCode, timezone];
}
