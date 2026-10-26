import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/l10n.dart';

/// Localized, user-facing copy for generic failures. Backend messages are
/// English diagnostics and are never shown directly.
///
/// Feature screens switch on their own `FeatureFailure` subtypes first and
/// fall back to this for everything else.
extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    ValidationFailure() => l10n.errorValidation,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    SessionExpiredFailure() => l10n.sessionExpired,
    NotFoundFailure() => l10n.errorNotFound,
    RateLimitedFailure() => l10n.errorRateLimited,
    ServerFailure() => l10n.errorServer,
    UnknownFailure() || FeatureFailure() => l10n.errorUnknown,
  };
}
