import 'package:baytna_worker/features/auth/domain/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? sy(String s) => PhoneNumber.toE164(s, prefix: '+963');
  String? iq(String s) => PhoneNumber.toE164(s, prefix: '+964');

  test('national format with trunk 0', () {
    expect(sy('0911111111'), '+963911111111');
    expect(iq('07701234567'), '+9647701234567');
  });

  test('without trunk 0, with separators', () {
    expect(sy('911 111 111'), '+963911111111');
    expect(sy('(0)91-111-1111'), '+963911111111');
  });

  test('international forms', () {
    expect(sy('+963 911 111 111'), '+963911111111');
    expect(sy('00963911111111'), '+963911111111');
    expect(sy('963911111111'), '+963911111111');
  });

  test('Arabic-Indic and Persian digits', () {
    expect(sy('٠٩١١١١١١١١'), '+963911111111');
    expect(iq('۰۷۷۰۱۲۳۴۵۶۷'), '+9647701234567');
  });

  test('rejects garbage, too short, and other countries', () {
    expect(sy(''), isNull);
    expect(sy('12345'), isNull);
    expect(sy('09abc11111'), isNull);
    expect(sy('+964 770 123 4567'), isNull);
    expect(sy('0911111111111111'), isNull);
  });
}
