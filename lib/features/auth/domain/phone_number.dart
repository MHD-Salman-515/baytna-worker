/// Normalizes user-typed phone numbers to E.164 for a given country prefix.
///
/// Accepts what people actually type: Arabic-Indic (٠١٢) and Persian (۰۱۲)
/// digits, spaces/dashes/parentheses, a national trunk "0" (0911 111 111),
/// or the full number with "+963", "00963" or "963".
///
/// Only structural checks happen here; the backend validates the number
/// against the country's real numbering plan and its 400 is surfaced as
/// `InvalidPhoneNumber`.
abstract final class PhoneNumber {
  /// E.164 allows at most 15 digits including the country code.
  static const _maxE164Digits = 15;
  static const _minNationalDigits = 7;

  /// Returns the E.164 string, or null when the input can't be a valid
  /// number for [prefix] (e.g. "+963").
  static String? toE164(String input, {required String prefix}) {
    final cc = prefix.replaceAll('+', '');
    var digits = asciiDigits(input).replaceAll(RegExp(r'[\s\-().]'), '');

    if (digits.startsWith('+')) {
      digits = digits.substring(1);
      if (!digits.startsWith(cc)) return null; // a different country's number
      digits = digits.substring(cc.length);
    } else if (digits.startsWith('00$cc')) {
      digits = digits.substring(2 + cc.length);
    } else if (digits.startsWith(cc) &&
        digits.length - cc.length >= _minNationalDigits + 1) {
      // "963911111111" — country code without '+'. The length guard keeps a
      // national number that merely starts with the same digits intact.
      digits = digits.substring(cc.length);
    }

    // Drop the national trunk prefix: 0911111111 → 911111111.
    digits = digits.replaceFirst(RegExp('^0+'), '');

    if (!RegExp(r'^\d+$').hasMatch(digits)) return null;
    if (digits.length < _minNationalDigits) return null;
    if (cc.length + digits.length > _maxE164Digits) return null;
    return '+$cc$digits';
  }

  /// Maps Arabic-Indic and Extended Arabic-Indic (Persian) digits to ASCII.
  static String asciiDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x30 + rune - 0x0660);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(0x30 + rune - 0x06F0);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}
