import 'dart:convert';

/// Reads the `exp` claim so we can refresh *before* sending a request with a
/// dead access token. The signature is not (and cannot be) verified here; this
/// is only a scheduling hint — the server's 401 remains the source of truth.
abstract final class Jwt {
  static DateTime? expiry(String token) {
    final claims = _claims(token);
    if (claims != null && claims['exp'] is num) {
      final seconds = (claims['exp'] as num).toInt();
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
    }
    return null;
  }

  /// The `roles` claim, e.g. `["CUSTOMER", "WORKER"]`. The backend authorizes
  /// role-gated routes from this claim, NOT from the database, so it only
  /// changes when the token is refreshed (see WorkerRepositoryImpl.apply).
  static List<String> roles(String token) {
    final roles = _claims(token)?['roles'];
    return roles is List ? roles.whereType<String>().toList(growable: false) : const [];
  }

  static Map<String, dynamic>? _claims(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = jsonDecode(payload);
      return claims is Map<String, dynamic> ? claims : null;
    } on FormatException {
      return null;
    }
  }

  /// True when the token expires within [leeway] (to absorb clock skew and
  /// request latency). Tokens without a readable `exp` are treated as valid.
  static bool isExpired(
    String token, {
    Duration leeway = Duration.zero,
    DateTime? now,
  }) {
    final exp = expiry(token);
    if (exp == null) return false;
    return !(now ?? DateTime.now().toUtc()).add(leeway).isBefore(exp);
  }
}
