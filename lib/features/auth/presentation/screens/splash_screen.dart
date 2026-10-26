import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/widgets/directional_icon.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shown while the session (AuthBloc) and then her worker profile
/// (WorkerBloc) are resolved. It makes no routing decisions itself — the
/// router redirects once both are known. If the profile can't be loaded it
/// offers a retry: without her status the app can't know what she may see.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final worker = context.watch<WorkerBloc>().state;
    final signedIn = context.watch<AuthBloc>().state is AuthAuthenticated;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Icon(Icons.cleaning_services_rounded, size: 52, color: scheme.onPrimary),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.appTitle,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.appTagline,
                style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              if (signedIn && worker is WorkerLoadFailed) ...[
                Text(context.l10n.splashLoadFailed, style: theme.textTheme.titleMedium),
                FailureView(
                  failure: worker.failure,
                  onRetry: () => context.read<WorkerBloc>().add(const WorkerLoadRequested()),
                ),
                TextButton.icon(
                  onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  icon: const DirectionalIcon(Icons.logout_rounded),
                  label: Text(context.l10n.logout),
                ),
              ] else
                const SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 3)),
            ],
          ),
        ),
      ),
    );
  }
}
