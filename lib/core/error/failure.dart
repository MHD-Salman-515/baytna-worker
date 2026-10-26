import 'package:equatable/equatable.dart';

/// Every error that can reach a bloc. The network layer converts all
/// `DioException`s (and backend error envelopes) into one of these, so UI code
/// can `switch` exhaustively and never sees transport details.
///
/// [debugMessage] is the backend/diagnostic text — for logs, never for users.
/// Users see localized copy chosen by failure type (see `failure_l10n.dart`).
sealed class Failure extends Equatable implements Exception {
  const Failure([this.debugMessage]);

  final String? debugMessage;

  @override
  List<Object?> get props => [debugMessage];

  @override
  String toString() => 'Failure(${debugMessage ?? ''})';
}

/// No connection, DNS failure, CORS rejection, connection reset.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.debugMessage]);
}

/// The server didn't answer within the (already generous) timeouts.
final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.debugMessage]);
}

/// 400 / 422. The backend sends `message` as either a string or a list of
/// validation strings; both arrive here as [messages].
final class ValidationFailure extends Failure {
  const ValidationFailure(this.messages) : super(null);

  final List<String> messages;

  @override
  String? get debugMessage => messages.join('; ');

  @override
  List<Object?> get props => [messages];
}

/// 401 that could not be fixed by refreshing, or 403.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.debugMessage]);
}

/// The refresh token was rejected; local tokens are cleared and the
/// AuthBloc has been told to sign out.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.debugMessage]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.debugMessage]);
}

/// 429 — e.g. OTP requested again inside the 60-second cooldown.
final class RateLimitedFailure extends Failure {
  const RateLimitedFailure([super.debugMessage]);
}

/// 5xx after the cold-start retries were exhausted.
final class ServerFailure extends Failure {
  const ServerFailure(this.statusCode, [super.debugMessage]);

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode, debugMessage];
}

/// Malformed payloads, programming errors, anything unclassified.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.debugMessage]);
}

/// Base for feature-specific failures that a repository derives from a
/// generic one (e.g. a 400 whose message means "too many OTP attempts").
/// Features declare their own `sealed` subtype of this so their UI can
/// switch exhaustively over it too.
abstract base class FeatureFailure extends Failure {
  const FeatureFailure([super.debugMessage]);
}
