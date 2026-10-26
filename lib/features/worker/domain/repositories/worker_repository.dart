import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/worker/domain/entities/profile_input.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';

abstract interface class WorkerRepository {
  /// Her worker profile, or `null` if she has never applied.
  ///
  /// [accountRoles] are the roles from GET /auth/me. When the database says
  /// WORKER but the access token doesn't yet, the token is refreshed first.
  Future<Result<WorkerProfile?>> fetchProfile({required List<String> accountRoles});

  /// POST /workers/me/apply, then refreshes the access token so it carries
  /// the WORKER role. Idempotent; never resets an APPROVED/SUSPENDED profile.
  Future<Result<WorkerProfile>> apply();

  Future<Result<WorkerProfile>> updateProfile(ProfileInput input);

  /// DRAFT/REJECTED → PENDING_REVIEW. Fails with `MissingRequiredDocuments`.
  Future<Result<WorkerProfile>> submitForReview();
}
