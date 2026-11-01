import 'package:equatable/equatable.dart';

/// An amount of money: an INTEGER plus an explicit currency, never a double.
/// Amounts are shown exactly as the backend sends them (`6000` SYP is "6,000
/// ل.س"), matching the customer app; nothing here divides or rounds.
class Money extends Equatable {
  const Money(this.amount, this.currency);

  final int amount;
  final String currency;

  bool get isNegative => amount < 0;

  @override
  List<Object?> get props => [amount, currency];
}

/// Reads a money integer from JSON. A fractional value means the contract
/// changed, and silently rounding someone's earnings would be worse than
/// failing, so it throws (`guard` turns that into a failure).
int moneyFromJson(Object? json) => switch (json) {
  final int value => value,
  final double value when value == value.truncateToDouble() => value.toInt(),
  _ => throw FormatException('Expected an integer amount, got $json'),
};

int? moneyFromJsonOrNull(Object? json) => json == null ? null : moneyFromJson(json);

/// "12,000 ل.س" / "12,000 SYP". Grouped Western digits in both languages,
/// like the phone numbers. The signed number is a Unicode LTR isolate, so a
/// minus sign stays attached to its digits inside Arabic text.
String formatMoney(Money money, String languageCode) {
  final digits = _groupDigits(money.amount.abs());
  final number = money.isNegative ? '\u2066-$digits\u2069' : digits;
  return '$number ${currencySymbol(money.currency, languageCode)}';
}

/// [formatMoney] with an explicit `+` on credits, for ledgers.
String formatSignedMoney(Money money, String languageCode) {
  if (money.isNegative || money.amount == 0) return formatMoney(money, languageCode);
  return '\u2066+${_groupDigits(money.amount)}\u2069 ${currencySymbol(money.currency, languageCode)}';
}

String currencySymbol(String code, String languageCode) {
  if (languageCode != 'ar') return code;
  return switch (code) {
    'SYP' => 'ل.س',
    'IQD' => 'د.ع',
    _ => code,
  };
}

String _groupDigits(int value) {
  final raw = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) out.write(',');
    out.write(raw[i]);
  }
  return out.toString();
}
