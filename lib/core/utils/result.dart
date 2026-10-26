import 'package:baytna_worker/core/error/failure.dart';
import 'package:flutter/foundation.dart';

/// What repositories return. Blocs `switch` on it; nothing throws past a
/// repository boundary.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [body] and converts whatever it throws into an [Err]. A `Failure`
/// passes through; anything else (a `TypeError` from a malformed payload, a
/// `FormatException`) becomes [UnknownFailure] rather than escaping to the UI.
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on Failure catch (failure) {
    return Err(failure);
  } on Object catch (error, stack) {
    debugPrint('Unexpected error: $error\n$stack');
    return Err(UnknownFailure(error.toString()));
  }
}
