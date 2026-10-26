import 'dart:async';

import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/router/app_redirect.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/auth/presentation/screens/country_selection_screen.dart';
import 'package:baytna_worker/features/auth/presentation/screens/otp_screen.dart';
import 'package:baytna_worker/features/auth/presentation/screens/phone_entry_screen.dart';
import 'package:baytna_worker/features/auth/presentation/screens/splash_screen.dart';
import 'package:baytna_worker/features/documents/presentation/screens/documents_screen.dart';
import 'package:baytna_worker/features/home/presentation/screens/home_screen.dart';
import 'package:baytna_worker/features/onboarding/presentation/screens/apply_screen.dart';
import 'package:baytna_worker/features/onboarding/presentation/screens/profile_form_screen.dart';
import 'package:baytna_worker/features/onboarding/presentation/screens/status_screen.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._auth, this._worker);

  final AuthBloc _auth;
  final WorkerBloc _worker;

  late final GoRouter config = GoRouter(
    initialLocation: AppRoutes.splash,
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
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
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
