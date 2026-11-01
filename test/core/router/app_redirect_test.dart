import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/router/app_redirect.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

WorkerLoaded _loaded(VerificationStatus v, {FinancialStatus f = FinancialStatus.active}) => WorkerLoaded(
  WorkerProfile(id: 'w', countryId: 'c', verificationStatus: v, financialStatus: f),
);

void main() {
  const authed = AuthAuthenticated(User(id: 'u', phone: '+963911111111', countryId: 'c'));
  const guest = AuthUnauthenticated();

  String? go(AuthState a, WorkerState w, String loc) => appRedirect(a, w, Uri.parse(loc));

  /// Every route the app has, plus one that doesn't exist yet (a future
  /// "work" route) — the allow-list must cover it by default.
  const everyRoute = [
    '/status',
    '/status/profile',
    '/status/documents',
    '/home',
    '/work',
    '/work/availability',
    '/work/services/new',
    '/wallet',
    '/bookings/b1',
    '/apply',
    '/bookings',
  ];

  group('session', () {
    test('unknown session → splash, remembering the target', () {
      expect(go(const AuthUnknown(), const WorkerUnknown(), '/splash'), isNull);
      expect(go(const AuthUnknown(), const WorkerUnknown(), '/home'), '/splash?from=%2Fhome');
    });

    test('signed out → only the auth flow, regardless of any stale worker state', () {
      expect(go(guest, const WorkerUnknown(), '/auth/country'), isNull);
      expect(go(guest, _loaded(VerificationStatus.approved), '/home'), '/auth/country');
    });
  });

  group('signed in, profile not known yet', () {
    test('loading or failed → splash (never assumed approved)', () {
      for (final w in [const WorkerUnknown(), const WorkerLoadFailed(NetworkFailure())]) {
        expect(go(authed, w, '/home'), '/splash?from=%2Fhome');
        expect(go(authed, w, '/splash?from=%2Fhome'), isNull);
      }
    });
  });

  group('never applied', () {
    test('only /apply', () {
      for (final r in everyRoute.where((r) => r != '/apply')) {
        expect(go(authed, const WorkerNotApplied(), r), '/apply', reason: r);
      }
      expect(go(authed, const WorkerNotApplied(), '/apply'), isNull);
      expect(go(authed, const WorkerNotApplied(), '/auth/otp?x=1'), '/apply');
    });
  });

  group('NOT approved can never reach work', () {
    for (final v in VerificationStatus.values.where((v) => !v.isApproved)) {
      test('${v.name}: /home and unknown future routes → /status', () {
        expect(go(authed, _loaded(v), '/home'), '/status');
        expect(go(authed, _loaded(v), '/bookings'), '/status');
        expect(go(authed, _loaded(v), '/wallet'), '/status');
        expect(go(authed, _loaded(v), '/work'), '/status');
        expect(go(authed, _loaded(v), '/work/services/new'), '/status');
        expect(go(authed, _loaded(v), '/splash?from=%2Fhome'), '/status');
      });
    }

    test('never-approved statuses hold no job, so a job screen stays closed', () {
      for (final v in [VerificationStatus.draft, VerificationStatus.pendingReview]) {
        expect(go(authed, _loaded(v), '/bookings/b1'), '/status');
      }
    });

    test('suspended mid-job: she stays on the job, and only there', () {
      for (final v in [VerificationStatus.suspended, VerificationStatus.rejected, VerificationStatus.unknown]) {
        expect(go(authed, _loaded(v), '/bookings/b1'), isNull, reason: 'work in hand is never stranded');
        expect(go(authed, _loaded(v), '/splash?from=%2Fbookings%2Fb1'), '/bookings/b1');
        expect(go(authed, _loaded(v), '/bookings'), '/status', reason: 'the list stays closed');
        expect(go(authed, _loaded(v), '/bookings/b1/x'), '/status');
        expect(go(authed, _loaded(v), '/home'), '/status');
      }
    });

    test('DRAFT and REJECTED may edit profile and documents', () {
      for (final v in [VerificationStatus.draft, VerificationStatus.rejected]) {
        expect(go(authed, _loaded(v), '/status'), isNull);
        expect(go(authed, _loaded(v), '/status/profile'), isNull);
        expect(go(authed, _loaded(v), '/status/documents'), isNull);
      }
    });

    test('PENDING_REVIEW, SUSPENDED, unknown: status screen only', () {
      for (final v in [VerificationStatus.pendingReview, VerificationStatus.suspended, VerificationStatus.unknown]) {
        expect(go(authed, _loaded(v), '/status'), isNull);
        expect(go(authed, _loaded(v), '/status/profile'), '/status');
        expect(go(authed, _loaded(v), '/status/documents'), '/status');
      }
    });

    test('signing in lands on /status', () {
      expect(go(authed, _loaded(VerificationStatus.draft), '/splash?from=%2Fauth%2Fotp'), '/status');
      expect(go(authed, _loaded(VerificationStatus.draft), '/auth/otp?a=b'), '/status');
    });
  });

  group('APPROVED', () {
    final approved = _loaded(VerificationStatus.approved);

    test('reaches home and future work routes; lands on /home', () {
      expect(go(authed, approved, '/home'), isNull);
      expect(go(authed, approved, '/bookings'), isNull);
      expect(go(authed, approved, '/splash'), '/home');
      expect(go(authed, approved, '/apply'), '/home');
    });

    test('onboarding steps are closed', () {
      expect(go(authed, approved, '/status/profile'), '/home');
      expect(go(authed, approved, '/status/documents'), '/home');
    });

    test('financial suspension does not change routing (it is independent)', () {
      final suspendedWallet = _loaded(VerificationStatus.approved, f: FinancialStatus.suspended);
      expect(go(authed, suspendedWallet, '/home'), isNull);
      // She must be able to reach a job in progress, and her wallet to settle.
      expect(go(authed, suspendedWallet, '/bookings/b1'), isNull);
      expect(go(authed, suspendedWallet, '/wallet'), isNull);
    });

    test('resumes a local page after the splash, never an external one', () {
      expect(go(authed, approved, '/splash?from=%2Fbookings'), '/bookings');
      expect(go(authed, approved, '/splash?from=%2F%2Fevil.example'), '/home');
    });
  });
}
