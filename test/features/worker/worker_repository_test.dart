import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:baytna_worker/core/utils/jwt.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/worker/data/datasources/worker_remote_data_source.dart';
import 'package:baytna_worker/features/worker/data/repositories/worker_repository_impl.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/worker_failures.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_harness.dart';
import '../../helpers/fake_backend.dart';

const _profileJson = <String, Object?>{
  'id': 'w1',
  'userId': 'u1',
  'countryId': 'c1',
  'cityId': null,
  'yearsOfExperience': 0,
  'languages': <String>[],
  'serviceAreas': <String>[],
  'verificationStatus': 'DRAFT',
  'rejectionReason': null,
  'submittedAt': null,
  'financialStatus': 'ACTIVE',
};

/// Like staging: the role is a JWT claim. `apply` adds WORKER to the user,
/// but only a refreshed token carries it; worker routes 403 without it.
class _WorkerBackend {
  bool applied = false;
  int generation = 1;

  String access() => testJwt(roles: applied && generation > 1 ? ['CUSTOMER', 'WORKER'] : ['CUSTOMER'], tag: '$generation');

  bool _tokenHasWorker(Object? auth) {
    final token = (auth as String?)?.replaceFirst('Bearer ', '') ?? '';
    return Jwt.roles(token).contains('WORKER');
  }

  Map<String, Handler> get routes => {
    'POST /api/v1/workers/me/apply': (_, _) async {
      applied = true;
      return (201, {'success': true, 'data': _profileJson});
    },
    'GET /api/v1/workers/me/profile': (o, _) async => _tokenHasWorker(o.headers['Authorization'])
        ? FakeBackend.ok(_profileJson)
        : FakeBackend.error(403, 'Insufficient role'),
    'POST /api/v1/workers/me/submit': (o, _) async =>
        FakeBackend.error(400, 'Cannot submit for review: missing or rejected required documents (required: NATIONAL_ID_FRONT, NATIONAL_ID_BACK, CRIMINAL_RECORD)'),
    'POST /api/v1/auth/refresh': (_, body) async {
      generation++;
      return FakeBackend.ok({'accessToken': access(), 'refreshToken': 'refresh-$generation'});
    },
  };
}

void main() {
  late _WorkerBackend server;
  late ApiHarness h;
  late WorkerRepositoryImpl repo;

  setUp(() {
    server = _WorkerBackend();
    h = ApiHarness(server.routes, tokens: AuthTokens(accessToken: server.access(), refreshToken: 'refresh-1'));
    repo = WorkerRepositoryImpl(WorkerRemoteDataSource(h.api), h.storage, h.refresher);
  });

  test('a customer who never applied: no profile, and no request at all', () async {
    final result = await repo.fetchProfile(accountRoles: const ['CUSTOMER']);
    expect(result, isA<Ok<WorkerProfile?>>().having((r) => r.value, 'value', isNull));
    expect(h.backend.requests, isEmpty);
  });

  test('apply → token refreshed EXPLICITLY → worker routes authorize', () async {
    final applied = await repo.apply();
    expect(applied, isA<Ok<WorkerProfile>>());
    expect((applied as Ok<WorkerProfile>).value.verificationStatus, VerificationStatus.draft);
    expect(h.backend.requests.map((r) => '${r.method} ${r.uri.path}'), [
      'POST /api/v1/workers/me/apply',
      'POST /api/v1/auth/refresh',
    ]);
    expect(Jwt.roles(h.storage.tokens!.accessToken), contains('WORKER'));

    // The very next worker call succeeds (would be 403 with the old token).
    final profile = await repo.fetchProfile(accountRoles: const ['CUSTOMER']);
    expect(profile, isA<Ok<WorkerProfile?>>().having((r) => r.value?.id, 'id', 'w1'));
  });

  test('account has WORKER but the token predates it → refresh, then load', () async {
    server.applied = true; // applied on another device; our token is stale
    final result = await repo.fetchProfile(accountRoles: const ['CUSTOMER', 'WORKER']);
    expect(result, isA<Ok<WorkerProfile?>>().having((r) => r.value?.id, 'id', 'w1'));
    expect(h.backend.count('POST /api/v1/auth/refresh'), 1);
    expect(h.backend.count('GET /api/v1/workers/me/profile'), 1); // no wasted 403
  });

  test('refresh after apply that still lacks WORKER → WorkerRoleNotGranted (retryable)', () async {
    h = ApiHarness({
      ...server.routes,
      'POST /api/v1/auth/refresh': (_, _) async =>
          FakeBackend.ok({'accessToken': testJwt(), 'refreshToken': 'r2'}),
    }, tokens: AuthTokens(accessToken: server.access(), refreshToken: 'refresh-1'));
    repo = WorkerRepositoryImpl(WorkerRemoteDataSource(h.api), h.storage, h.refresher);
    final result = await repo.apply();
    expect(result, isA<Err<WorkerProfile>>().having((e) => e.failure, 'failure', isA<WorkerRoleNotGranted>()));
  });

  test('submit with missing documents → MissingRequiredDocuments', () async {
    server
      ..applied = true
      ..generation = 2;
    h.storage.tokens = AuthTokens(accessToken: server.access(), refreshToken: 'refresh-2');
    final result = await repo.submitForReview();
    expect(result, isA<Err<WorkerProfile>>().having((e) => e.failure, 'failure', isA<MissingRequiredDocuments>()));
  });
}
