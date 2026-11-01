import 'package:baytna_worker/core/format/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String ltr(String s) => '\u2066$s\u2069';

  test('groups digits, no rounding, local symbol', () {
    expect(formatMoney(const Money(12000, 'SYP'), 'ar'), '12,000 ل.س');
    expect(formatMoney(const Money(12000, 'SYP'), 'en'), '12,000 SYP');
    expect(formatMoney(const Money(999, 'IQD'), 'ar'), '999 د.ع');
    expect(formatMoney(const Money(1234567890123, 'SYP'), 'en'), '1,234,567,890,123 SYP');
    expect(formatMoney(const Money(0, 'SYP'), 'en'), '0 SYP');
  });

  test('negative amounts keep the minus attached inside RTL text', () {
    expect(formatMoney(const Money(-1800, 'SYP'), 'ar'), '${ltr('-1,800')} ل.س');
  });

  test('ledger amounts carry an explicit sign on credits only', () {
    expect(formatSignedMoney(const Money(5000, 'SYP'), 'en'), '${ltr('+5,000')} SYP');
    expect(formatSignedMoney(const Money(-5000, 'SYP'), 'en'), '${ltr('-5,000')} SYP');
    expect(formatSignedMoney(const Money(0, 'SYP'), 'en'), '0 SYP');
  });

  test('money from JSON is integer only; a fraction is an error, never rounded', () {
    expect(moneyFromJson(6000), 6000);
    expect(moneyFromJson(-1800), -1800);
    expect(moneyFromJson(6000.0), 6000);
    expect(() => moneyFromJson(1800.5), throwsFormatException);
    expect(() => moneyFromJson('6000'), throwsFormatException);
    expect(() => moneyFromJson(null), throwsFormatException);
    expect(moneyFromJsonOrNull(null), isNull);
  });
}
