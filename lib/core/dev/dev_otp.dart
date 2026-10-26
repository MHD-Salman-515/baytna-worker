import 'package:baytna_worker/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

/// DEBUG-ONLY access to staging's GET /dev/last-otp, so you can log in while
/// developing without receiving an SMS.
///
/// How it is removed from release builds (not merely hidden):
///  * [_key] is a compile-time constant that is `''` unless `kDebugMode` —
///    itself a constant `false` in profile/release — so the key never enters
///    a release binary, even if `--dart-define-from-file` is passed.
///  * [enabled] is therefore a constant `false` in release, and every call site
///    is guarded by `if (DevOtp.enabled)`, so the compiler drops this class,
///    the endpoint path, the header name and the button widget entirely.
///    (Verified by grepping a release `main.dart.js`; see README.)
///
/// The key comes from the gitignored `secrets.json`
/// (`--dart-define-from-file=secrets.json`). Never hardcode it.
abstract final class DevOtp {
  static const String _key = kDebugMode ? String.fromEnvironment('DEV_OTP_KEY') : '';

  static const bool enabled = kDebugMode && _key != '';

  /// The most recent code issued for [phoneE164]. The backend answers 404 for
  /// both an unknown phone and a bad key (by design).
  static Future<String> fetchLastCode(ApiClient api, String phoneE164) => api.get(
    '/dev/last-otp',
    query: {'phone': phoneE164},
    headers: {'x-dev-otp-key': _key},
    authenticated: false,
    decode: (data) => switch (data) {
      {'code': final String code} => code,
      final String code => code,
      _ => throw FormatException('Unexpected /dev/last-otp payload: $data'),
    },
  );
}
