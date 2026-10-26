import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/token_refresher.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/jwt.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/worker/data/datasources/worker_remote_data_source.dart';
import 'package:baytna_worker/features/worker/domain/entities/profile_input.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:baytna_worker/features/worker/domain/worker_failures.dart';
import 'package:injectable/injectable.dart';

/// THE ROLE LIVES IN THE JWT. POST /workers/me/apply adds WORKER to the user
/// in the database, but the access token she holds was minted before that,
/// and every other /workers/me route authorizes from the token's `roles`
/// claim — answering 403 "Insufficient role" (not 401, so the refresh
/// interceptor never steps in). This repository therefore refreshes the token
/// EXPLICITLY after applying, and whenever the account has the role but the
/// token doesn't. Refreshes go through the single-flight [TokenRefresher], so
/// they can never race another refresh into the backend's reuse detection.
@LazySingleton(as: WorkerRepository)
class WorkerRepositoryImpl implements WorkerRepository {
  WorkerRepositoryImpl(this._remote, this._tokens, this._refresher);

  final WorkerRemoteDataSource _remote;
  final TokenStorage _tokens;
  final TokenRefresher _refresher;

  @override
  Future<Result<WorkerProfile?>> fetchProfile({required List<String> accountRoles}) => guard(() async {
    final tokenHasRole = await _tokenHasWorkerRole();
    if (!tokenHasRole && !accountRoles.contains(UserRoles.worker)) return null; // never applied

    // Applied (e.g. on another device, or the post-apply refresh failed) but
    // this token predates it.
    if (!tokenHasRole) await _refresher.refresh();

    try {
      return (await _remote.getProfile()).toEntity();
    } on UnauthorizedFailure catch (f) {
      if (!_isInsufficientRole(f)) rethrow;
      // The token claims WORKER but the server disagrees (role revoked?).
      // Re-mint once and believe the new token.
      await _refresher.refresh();
      if (!await _tokenHasWorkerRole()) return null;
      return (await _remote.getProfile()).toEntity();
    } on NotFoundFailure {
      return null; // role without a profile: applying again creates it
    }
  });

  @override
  Future<Result<WorkerProfile>> apply() => guard(() async {
    final profile = await _remote.apply();
    final tokens = await _refresher.refresh();
    if (!Jwt.roles(tokens.accessToken).contains(UserRoles.worker)) {
      throw const WorkerRoleNotGranted('Refreshed token has no WORKER role');
    }
    return profile.toEntity();
  });

  @override
  Future<Result<WorkerProfile>> updateProfile(ProfileInput input) =>
      guard(() async => (await _remote.upsertProfile(input)).toEntity());

  @override
  Future<Result<WorkerProfile>> submitForReview() async {
    final result = await guard(() async => (await _remote.submit()).toEntity());
    return switch (result) {
      Err(failure: final ValidationFailure f) => Err(_submitFailure(f)),
      _ => result,
    };
  }

  /// Observed: "Cannot submit for review: missing or rejected required
  /// documents (…)" and "Cannot transition worker verification status from
  /// PENDING_REVIEW to PENDING_REVIEW".
  static Failure _submitFailure(ValidationFailure f) {
    final message = f.messages.join(' ').toLowerCase();
    if (message.contains('missing or rejected')) return MissingRequiredDocuments(f.debugMessage);
    if (message.contains('cannot transition')) return InvalidStatusTransition(f.debugMessage);
    return f;
  }

  static bool _isInsufficientRole(UnauthorizedFailure f) =>
      (f.debugMessage ?? '').toLowerCase().contains('insufficient role');

  Future<bool> _tokenHasWorkerRole() async {
    final tokens = await _tokens.read();
    return tokens != null && Jwt.roles(tokens.accessToken).contains(UserRoles.worker);
  }
}
