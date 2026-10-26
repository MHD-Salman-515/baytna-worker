typedef Json = Map<String, dynamic>;

/// Strict-cast helpers for decoding unwrapped `data` payloads. They throw
/// [FormatException] on a shape mismatch, which `guard` turns into an
/// `UnknownFailure`.
Json asJson(Object? value) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Expected a JSON object, got ${value.runtimeType}');
}

List<Json> asJsonList(Object? value) {
  if (value is List) return value.map(asJson).toList(growable: false);
  throw FormatException('Expected a JSON array, got ${value.runtimeType}');
}
