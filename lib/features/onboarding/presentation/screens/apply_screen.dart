import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/widgets/directional_icon.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/onboarding/presentation/bloc/apply/apply_bloc.dart';
import 'package:baytna_worker/features/worker/domain/worker_failures.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Signed in, never applied. Applying is the only thing she can do here.
class ApplyScreen extends StatelessWidget {
  const ApplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => getIt<ApplyBloc>(),
      child: BlocListener<ApplyBloc, ApplyState>(
        listenWhen: (_, next) => next is ApplySucceeded,
        // The WorkerBloc takes over; the router moves her to the status screen.
        listener: (context, state) =>
            context.read<WorkerBloc>().add(WorkerProfileChanged((state as ApplySucceeded).profile)),
        child: PageScaffold(
          title: l10n.applyTitle,
          subtitle: l10n.applySubtitle,
          actions: [
            IconButton(
              tooltip: l10n.logout,
              onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
              icon: const DirectionalIcon(Icons.logout_rounded),
            ),
          ],
          body: BlocBuilder<ApplyBloc, ApplyState>(
            builder: (context, state) {
              final error = switch (state) {
                ApplyFailed(failure: WorkerRoleNotGranted()) => l10n.applyRoleNotGranted,
                ApplyFailed(:final failure) => failure.message(l10n),
                ApplyIdle() || ApplyInProgress() || ApplySucceeded() => null,
              };
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Step(number: 1, icon: Icons.person_outline_rounded, text: l10n.applyStepProfile),
                  _Step(number: 2, icon: Icons.badge_outlined, text: l10n.applyStepDocuments),
                  _Step(number: 3, icon: Icons.verified_user_outlined, text: l10n.applyStepReview),
                  const Spacer(),
                  if (error != null) ...[
                    Text(
                      error,
                      key: const ValueKey('apply-error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 12),
                  ],
                  PrimaryButton(
                    key: const ValueKey('apply'),
                    label: l10n.applyAction,
                    loading: state is ApplyInProgress || state is ApplySucceeded,
                    onPressed: () => context.read<ApplyBloc>().add(const ApplySubmitted()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.icon, required this.text});

  final int number;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Icon(icon, size: 22, semanticLabel: '$number'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 8),
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
