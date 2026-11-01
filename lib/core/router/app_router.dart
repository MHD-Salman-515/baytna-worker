import 'dart:async';

import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/router/app_redirect.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/auth/presentation/screens/country_selection_screen.dart';
import 'package:baytna_worker/features/auth/presentation/screens/otp_screen.dart';
import 'package:baytna_worker/features/auth/presentation/screens/phone_entry_screen.dart';
import 'package:baytna_worker/features/auth/presentation/screens/splash_screen.dart';
import 'package:baytna_worker/features/availability/presentation/screens/availability_screen.dart';
import 'package:baytna_worker/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:baytna_worker/features/bookings/presentation/screens/jobs_screen.dart';
import 'package:baytna_worker/features/documents/presentation/screens/documents_screen.dart';
import 'package:baytna_worker/features/home/presentation/screens/home_shell.dart';
import 'package:baytna_worker/features/offerings/presentation/screens/offering_form_screen.dart';
import 'package:baytna_worker/features/offerings/presentation/screens/work_screen.dart';
import 'package:baytna_worker/features/onboarding/presentation/screens/apply_screen.dart';
import 'package:baytna_worker/features/onboarding/presentation/screens/profile_form_screen.dart';
import 'package:baytna_worker/features/onboarding/presentation/screens/status_screen.dart';
import 'package:baytna_worker/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._auth, this._worker);

  final AuthBloc _auth;
  final WorkerBloc _worker;

  /// Lets screens react to routes being pushed over / popped off them
  /// (RouteAware), e.g. the status screen reloading after the documents step.
  static final routeObserver = RouteObserver<ModalRoute<void>>();

  late final GoRouter config = GoRouter(
    initialLocation: AppRoutes.splash,
    observers: [routeObserver],
    refreshListenable: _StreamListenable([_auth.stream, _worker.stream]),
    redirect: (context, state) => appRedirect(_auth.state, _worker.state, state.uri),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.country, builder: (_, _) => const CountrySelectionScreen()),
      GoRoute(
        path: AppRoutes.phone,
        redirect: (_, state) => _require(state, ['countryId']),
        builder: (_, state) => PhoneEntryScreen(countryId: state.uri.queryParameters['countryId']!),
      ),
      GoRoute(
        path: AppRoutes.otp,
        redirect: (_, state) => _require(state, ['countryId', 'phone']),
        builder: (_, state) => OtpScreen(
          countryId: state.uri.queryParameters['countryId']!,
          phone: state.uri.queryParameters['phone']!,
        ),
      ),
      GoRoute(path: AppRoutes.apply, builder: (_, _) => const ApplyScreen()),
      GoRoute(
        path: AppRoutes.status,
        builder: (_, _) => const StatusScreen(),
        routes: [
          GoRoute(path: 'profile', builder: (_, _) => const ProfileFormScreen()),
          GoRoute(path: 'documents', builder: (_, _) => const DocumentsScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.home, builder: (_, _) => const JobsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.work, builder: (_, _) => const WorkScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.wallet, builder: (_, _) => const WalletScreen())],
          ),
        ],
      ),
      GoRoute(path: AppRoutes.availability, builder: (_, _) => const AvailabilityScreen()),
      GoRoute(path: AppRoutes.offeringNew, builder: (_, _) => const OfferingFormScreen()),
      GoRoute(
        path: '/work/services/:id',
        builder: (_, state) => OfferingFormScreen(offeringId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '${AppRoutes.bookingPrefix}/:id',
        builder: (_, state) => BookingDetailScreen(bookingId: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );

  /// A hand-edited or truncated URL restarts the flow instead of crashing.
  static String? _require(GoRouterState state, List<String> params) {
    final q = state.uri.queryParameters;
    return params.every((p) => (q[p] ?? '').isNotEmpty) ? null : AppRoutes.country;
  }
}

/// Re-runs redirects whenever the session or the worker profile changes.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(List<Stream<Object?>> streams) {
    _subs = [for (final s in streams) s.listen((_) => notifyListeners())];
  }

  late final List<StreamSubscription<Object?>> _subs;

  @override
  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    super.dispose();
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.errorNotFound),
            const SizedBox(height: 16),
            FilledButton(
              // The redirect sends her wherever her status allows.
              onPressed: () => context.go(AppRoutes.status),
              child: Text(context.l10n.continueAction),
            ),
          ],
        ),
      ),
    );
  }
}
