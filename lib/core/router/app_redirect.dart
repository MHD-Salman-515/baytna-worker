import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';

/// The routing policy, as a pure function of session, worker profile and
/// location. Returns where to go instead, or null to stay.
///
/// * auth unknown → splash, remembering where she was going;
/// * signed out → only the auth flow;
/// * signed in, profile loading or failed → splash (it shows the retry);
/// * never applied → only /apply;
/// * NOT APPROVED → an ALLOW-LIST per status, so any route added later is
///   unreachable by default until she is approved:
///     DRAFT / REJECTED       → status, profile, documents
///     PENDING_REVIEW / SUSPENDED / unknown → status only
/// * APPROVED → anything except auth, splash, apply and the onboarding steps.
String? appRedirect(AuthState auth, WorkerState worker, Uri location) {
  final path = location.path;
  final atSplash = path == AppRoutes.splash;
  final inAuthFlow = path.startsWith(AppRoutes.authPrefix);
  final from = atSplash ? location.queryParameters['from'] : null;

  String toSplash() => atSplash
      ? location.toString()
      : Uri(path: AppRoutes.splash, queryParameters: {'from': location.toString()}).toString();

  String? stayOr(String target) => target == location.toString() ? null : target;

  switch (auth) {
    case AuthUnknown():
      return atSplash ? null : toSplash();

    case AuthUnauthenticated():
      if (inAuthFlow) return null;
      if (from != null && from.startsWith(AppRoutes.authPrefix)) return from;
      return AppRoutes.country;

    case AuthAuthenticated():
      switch (worker) {
        case WorkerUnknown() || WorkerLoadFailed():
          return stayOr(toSplash());

        case WorkerNotApplied():
          return path == AppRoutes.apply ? null : AppRoutes.apply;

        case WorkerLoaded(:final profile):
          final allowed = _allowed(profile.verificationStatus);
          if (allowed(path)) return null;
          // Coming from the splash: resume where she was going if allowed.
          if (from != null && _isLocal(from) && allowed(Uri.parse(from).path)) return from;
          return profile.verificationStatus.isApproved ? AppRoutes.home : AppRoutes.status;
      }
  }
}

bool Function(String path) _allowed(VerificationStatus status) => switch (status) {
  VerificationStatus.draft || VerificationStatus.rejected => (p) =>
      p == AppRoutes.status || p == AppRoutes.profile || p == AppRoutes.documents,
  VerificationStatus.pendingReview ||
  VerificationStatus.suspended ||
  VerificationStatus.unknown => (p) => p == AppRoutes.status,
  VerificationStatus.approved => (p) =>
      p != AppRoutes.splash &&
      !p.startsWith(AppRoutes.authPrefix) &&
      p != AppRoutes.apply &&
      p != AppRoutes.profile &&
      p != AppRoutes.documents,
};

bool _isLocal(String uri) => uri.startsWith('/') && !uri.startsWith('//');
