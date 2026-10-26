import 'package:baytna_worker/core/error/failure.dart';

/// Worker-profile failures the repository derives from generic ones (the
/// backend encodes these cases only in the message text).
sealed class WorkerFailure extends FeatureFailure {
  const WorkerFailure([super.debugMessage]);
}

/// 400 on submit: "missing or rejected required documents". An EXPIRED
/// criminal record also counts as missing.
final class MissingRequiredDocuments extends WorkerFailure {
  const MissingRequiredDocuments([super.debugMessage]);
}

/// 400 "Cannot transition worker verification status from X to Y" — e.g. a
/// double submit. The local status is stale; reload the profile.
final class InvalidStatusTransition extends WorkerFailure {
  const InvalidStatusTransition([super.debugMessage]);
}

/// Applying succeeded but the refreshed access token still lacks the WORKER
/// role, so worker routes would keep answering 403. Retrying apply is safe.
final class WorkerRoleNotGranted extends WorkerFailure {
  const WorkerRoleNotGranted([super.debugMessage]);
}
