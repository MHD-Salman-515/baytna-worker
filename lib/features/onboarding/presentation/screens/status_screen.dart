import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/widgets/directional_icon.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/language_toggle_button.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/documents/domain/document_requirements.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/documents/presentation/widgets/document_labels.dart';
import 'package:baytna_worker/features/onboarding/domain/onboarding_checklist.dart';
import 'package:baytna_worker/features/onboarding/presentation/bloc/status/status_bloc.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/worker_failures.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:baytna_worker/features/worker/presentation/widgets/account_standing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Her home until she is APPROVED. Everything is driven by
/// `verificationStatus`; nothing here offers work.
///
/// Refreshes on pull, when the app returns to the foreground, and every
/// two minutes while she waits for review — so an approval shows up
/// without her doing anything.
class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  static const _pollInterval = Duration(minutes: 2);

  late final StatusBloc _status = getIt<StatusBloc>()..add(const StatusDocumentsRequested());
  late final AppLifecycleListener _lifecycle;
  late final Timer _poll;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _poll = Timer.periodic(_pollInterval, (_) {
      final worker = context.read<WorkerBloc>().state;
      if (worker case WorkerLoaded(profile: WorkerProfile(verificationStatus: VerificationStatus.pendingReview))) {
        _refresh();
      }
    });
  }

  @override
  void dispose() {
    _poll.cancel();
    _lifecycle.dispose();
    unawaited(_status.close());
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    context.read<WorkerBloc>().add(const WorkerRefreshRequested());
    _status.add(const StatusDocumentsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider.value(
      value: _status,
      child: BlocListener<StatusBloc, StatusState>(
        listenWhen: (prev, next) => prev.submit != next.submit,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          switch (state.submit) {
            case StatusSubmitSucceeded(:final profile):
              context.read<WorkerBloc>().add(WorkerProfileChanged(profile));
              messenger.showSnackBar(SnackBar(content: Text(l10n.statusSubmitted)));
            case StatusSubmitConflict():
              _refresh();
              messenger.showSnackBar(SnackBar(content: Text(l10n.statusTransitionConflict)));
            case StatusSubmitFailed(:final failure):
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    failure is MissingRequiredDocuments ? l10n.statusMissingDocuments : failure.message(l10n),
                  ),
                ),
              );
            case StatusSubmitIdle() || StatusSubmitting():
              break;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.statusTitle),
            actions: [
              IconButton(
                tooltip: l10n.statusRefresh,
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const LanguageToggleButton(),
              IconButton(
                key: const ValueKey('logout'),
                tooltip: l10n.logout,
                onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                icon: const DirectionalIcon(Icons.logout_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: PageScaffold.maxContentWidth),
                child: BlocBuilder<WorkerBloc, WorkerState>(
                  builder: (context, worker) => switch (worker) {
                    // The router only shows this screen with a loaded profile.
                    WorkerLoaded(:final profile) => RefreshIndicator(
                      onRefresh: () async => _refresh(),
                      child: _StatusBody(profile: profile),
                    ),
                    WorkerUnknown() || WorkerNotApplied() || WorkerLoadFailed() => const SizedBox.shrink(),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.profile});

  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<StatusBloc, StatusState>(
      builder: (context, state) {
        final now = getIt<Clock>().now();
        final documents = state.documentList;
        final status = profile.verificationStatus;
        final checklist = OnboardingChecklist.of(profile, documents, now);

        return ListView(
          // Pull-to-refresh must work even when the content is short.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
          children: [
            _Headline(profile: profile, now: now),
            const SizedBox(height: 20),
            if (status == VerificationStatus.rejected && profile.rejectionReason != null) ...[
              _RejectionNote(reason: profile.rejectionReason!),
              const SizedBox(height: 16),
            ],
            if (status.isEditable) ...[
              _Checklist(checklist: checklist, documents: documents, documentsLoaded: state.documents is StatusDocumentsLoaded),
              const SizedBox(height: 16),
              PrimaryButton(
                key: const ValueKey('submit'),
                label: status == VerificationStatus.rejected ? l10n.statusResubmit : l10n.statusSubmit,
                loading: state.submit is StatusSubmitting,
                onPressed: checklist.canSubmit
                    ? () => context.read<StatusBloc>().add(const StatusSubmitRequested())
                    : null,
              ),
              if (!checklist.canSubmit) ...[
                const SizedBox(height: 8),
                Text(l10n.statusSubmitBlocked, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 20),
            ],
            if (status == VerificationStatus.pendingReview && documents.isNotEmpty) ...[
              _SubmittedDocuments(documents: documents, now: now),
              const SizedBox(height: 16),
            ],
            if (status.isApproved) ...[
              PrimaryButton(
                key: const ValueKey('continue-approved'),
                label: l10n.statusContinue,
                onPressed: () => context.go(AppRoutes.home),
              ),
              const SizedBox(height: 20),
            ],
            AccountStandingCard(profile: profile),
            const SizedBox(height: 12),
            Text(
              l10n.statusPullToRefresh,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        );
      },
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.profile, required this.now});

  final WorkerProfile profile;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, color, title, body) = switch (profile.verificationStatus) {
      VerificationStatus.draft => (Icons.edit_note_rounded, scheme.primary, l10n.statusDraftTitle, l10n.statusDraftBody),
      VerificationStatus.pendingReview => (Icons.hourglass_top_rounded, scheme.secondary, l10n.statusPendingTitle, l10n.statusPendingBody),
      VerificationStatus.rejected => (Icons.report_gmailerrorred_rounded, scheme.error, l10n.statusRejectedTitle, l10n.statusRejectedBody),
      VerificationStatus.suspended => (Icons.block_rounded, scheme.error, l10n.statusSuspendedTitle, l10n.statusSuspendedBody),
      VerificationStatus.approved => (Icons.verified_rounded, scheme.primary, l10n.statusApprovedTitle, l10n.statusApprovedBody),
      VerificationStatus.unknown => (Icons.help_outline_rounded, scheme.outline, l10n.statusUnknownTitle, l10n.statusUnknownBody),
    };
    final submittedAt = profile.submittedAt;

    return Column(
      key: ValueKey('status-${profile.verificationStatus.apiValue}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 48, color: color),
        const SizedBox(height: 12),
        Text(
          title,
          key: const ValueKey('status-title'),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(body, style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
        if (profile.verificationStatus == VerificationStatus.pendingReview && submittedAt != null) ...[
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _waitingFor(l10n, now.difference(submittedAt)),
                          key: const ValueKey('waiting-for'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.statusSubmittedAt(_formatDateTime(context, submittedAt)),
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _waitingFor(AppLocalizations l10n, Duration waited) {
    final d = waited.isNegative ? Duration.zero : waited; // device clock behind the server
    if (d.inDays >= 1) return l10n.statusWaitingDays(d.inDays);
    if (d.inHours >= 1) return l10n.statusWaitingHours(d.inHours);
    return l10n.statusWaitingMinutes(d.inMinutes);
  }
}

class _RejectionNote extends StatelessWidget {
  const _RejectionNote({required this.reason});

  final LocalizedText reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      key: const ValueKey('rejection-reason'),
      decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.statusRejectedReason,
              style: theme.textTheme.labelLarge?.copyWith(color: scheme.onErrorContainer, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(context.localize(reason), style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onErrorContainer)),
          ],
        ),
      ),
    );
  }
}

/// DRAFT / REJECTED: profile + each required document, with the way to fix it.
class _Checklist extends StatelessWidget {
  const _Checklist({required this.checklist, required this.documents, required this.documentsLoaded});

  final OnboardingChecklist checklist;
  final List<WorkerDocument> documents;
  final bool documentsLoaded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = getIt<Clock>().now();
    final toReplace = [
      for (final type in DocumentType.required)
        if (DocumentRequirements.stateOf(DocumentRequirements.current(documents, type), now)
            case RequirementState.rejected || RequirementState.expired)
          type,
    ];

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              key: const ValueKey('step-profile'),
              leading: _StepIcon(done: checklist.profileComplete),
              title: Text(l10n.statusStepProfile, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(checklist.profileComplete ? l10n.statusStepDone : l10n.statusStepTodo),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => unawaited(context.push(AppRoutes.profile)),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              key: const ValueKey('step-documents'),
              leading: documentsLoaded
                  ? _StepIcon(done: checklist.documentsComplete)
                  : const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              title: Text(l10n.statusStepDocuments, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(checklist.documentsComplete ? l10n.statusStepDone : l10n.statusStepTodo),
              trailing: const Icon(Icons.chevron_right_rounded),
              // Documents only make sense once her profile (and city) exist.
              enabled: checklist.profileComplete,
              onTap: () => unawaited(context.push(AppRoutes.documents)),
            ),
            for (final type in DocumentType.required)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(72, 4, 16, 4),
                child: Row(
                  children: [
                    Expanded(child: Text(type.label(l10n), style: theme.textTheme.bodyMedium)),
                    RequirementBadge(
                      state: DocumentRequirements.stateOf(DocumentRequirements.current(documents, type), now),
                    ),
                  ],
                ),
              ),
            if (toReplace.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                child: Text(
                  l10n.statusDocumentsToReplace,
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.error),
                ),
              ),
              for (final type in toReplace)
                _RejectedDocumentLine(type: type, document: DocumentRequirements.current(documents, type)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RejectedDocumentLine extends StatelessWidget {
  const _RejectedDocumentLine({required this.type, required this.document});

  final DocumentType type;
  final WorkerDocument? document;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reason = document?.rejectionReason;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
      child: Text(
        reason == null ? '• ${type.label(l10n)}' : '• ${type.label(l10n)} — ${context.localize(reason)}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

/// PENDING_REVIEW: what she sent, each with its own review status.
class _SubmittedDocuments extends StatelessWidget {
  const _SubmittedDocuments({required this.documents, required this.now});

  final List<WorkerDocument> documents;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.statusStepDocuments, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final type in DocumentType.required)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(type.icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(type.label(l10n))),
                    RequirementBadge(
                      state: DocumentRequirements.stateOf(DocumentRequirements.current(documents, type), now),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Icon(
      done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
      color: done ? scheme.primary : scheme.outline,
    );
  }
}

String _formatDateTime(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).languageCode;
  return DateFormat.yMMMd(locale).add_jm().format(date.toLocal());
}
