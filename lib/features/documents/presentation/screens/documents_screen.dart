import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/documents/domain/document_requirements.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:baytna_worker/features/documents/presentation/bloc/documents/documents_bloc.dart';
import 'package:baytna_worker/features/documents/presentation/widgets/document_labels.dart';
import 'package:baytna_worker/features/documents/presentation/widgets/document_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The three required documents. Reachable only while her profile is
/// editable (router allow-list), which is also when the backend lets her
/// replace (delete) them.
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => getIt<DocumentsBloc>()..add(const DocumentsStarted()),
      child: BlocListener<DocumentsBloc, DocumentsState>(
        listenWhen: (prev, next) => prev.notice != next.notice && next.notice != null,
        listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.documentUploaded)),
        ),
        child: PageScaffold(
          title: l10n.documentsTitle,
          subtitle: l10n.documentsSubtitle,
          body: BlocBuilder<DocumentsBloc, DocumentsState>(
            buildWhen: (prev, next) => prev.load != next.load,
            builder: (context, state) => switch (state.load) {
              DocumentsLoading() => const Center(child: CircularProgressIndicator()),
              DocumentsLoadFailed(:final failure) => FailureView(
                failure: failure,
                onRetry: () => context.read<DocumentsBloc>().add(const DocumentsStarted()),
              ),
              DocumentsLoaded() => const _DocumentsList(),
            },
          ),
        ),
      ),
    );
  }
}

class _DocumentsList extends StatelessWidget {
  const _DocumentsList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocBuilder<DocumentsBloc, DocumentsState>(
      builder: (context, state) {
        final now = getIt<Clock>().now();
        final allDone = DocumentRequirements.outstanding(state.documents, now).isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => context.read<DocumentsBloc>().add(const DocumentsStarted()),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.documentsPrivacy,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final type in DocumentType.required) ...[
                      _DocumentCard(
                        type: type,
                        current: state.current(type),
                        draft: state.drafts[type],
                        now: now,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            if (allDone) ...[
              Text(l10n.documentsAllUploaded, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
            ],
            PrimaryButton(
              key: const ValueKey('documents-done'),
              label: l10n.documentsDone,
              onPressed: state.isUploading
                  ? null
                  : () => context.canPop() ? context.pop() : context.go(AppRoutes.status),
            ),
          ],
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.type, required this.current, required this.draft, required this.now});

  final DocumentType type;
  final WorkerDocument? current;
  final DocumentDraft? draft;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = DocumentRequirements.stateOf(current, now);
    final draft = this.draft;
    final reason = current?.rejectionReason;
    final expiresAt = current?.expiresAt;

    return Card(
      key: ValueKey('doc-${type.apiValue}'),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(type.icon, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(type.label(l10n), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (draft?.file != null && draft?.status is! DraftUploading)
                  StatusChip(
                    label: l10n.documentStateReady,
                    icon: Icons.upload_rounded,
                    foreground: scheme.onTertiaryContainer,
                    background: scheme.tertiaryContainer,
                  )
                else
                  RequirementBadge(key: ValueKey('badge-${type.apiValue}'), state: state),
              ],
            ),
            if (state == RequirementState.rejected && reason != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.documentRejectedReason(context.localize(reason)),
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
              ),
            ],
            if (expiresAt != null && draft == null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.documentExpiresOn(_formatDate(context, expiresAt)),
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (draft != null) ...[const SizedBox(height: 12), _DraftSection(type: type, draft: draft)],
            if (draft == null || draft.file == null) ...[
              const SizedBox(height: 12),
              _SourceButtons(type: type, replacing: current != null),
            ],
          ],
        ),
      ),
    );
  }
}

/// A picked file: preview, expiry date (criminal record), upload/retry.
class _DraftSection extends StatelessWidget {
  const _DraftSection({required this.type, required this.draft});

  final DocumentType type;
  final DocumentDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<DocumentsBloc>();
    final file = draft.file;
    final status = draft.status;
    final uploading = status is DraftUploading;
    final isRetry = draft.attempt != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (file != null) DocumentPreview(file: file),
        if (file != null && type.requiresExpiry) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: ValueKey('expiry-${type.apiValue}'),
            onPressed: uploading ? null : () => _pickExpiry(context),
            icon: const Icon(Icons.event_rounded),
            label: Text(
              draft.expiresAt == null
                  ? l10n.documentExpiryPick
                  : '${l10n.documentExpiryLabel}: ${_formatDate(context, draft.expiresAt!)}',
            ),
          ),
        ],
        if (status case DraftUploading(:final progress)) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, minHeight: 6, borderRadius: BorderRadius.circular(3)),
          const SizedBox(height: 6),
          Text(
            progress == null ? l10n.documentUploadingUnknown : l10n.documentUploading((progress * 100).round()),
            key: ValueKey('progress-${type.apiValue}'),
            style: theme.textTheme.bodySmall,
          ),
        ],
        if (status case DraftError(:final failure)) ...[
          const SizedBox(height: 10),
          Text(
            documentFailureMessage(failure, l10n),
            key: ValueKey('draft-error-${type.apiValue}'),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
        ],
        if (file != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: uploading ? null : () => bloc.add(DocumentDraftDiscarded(type)),
                  child: Text(l10n.documentDiscard),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  key: ValueKey('upload-${type.apiValue}'),
                  onPressed: uploading ? null : () => bloc.add(DocumentUploadRequested(type)),
                  icon: Icon(isRetry ? Icons.refresh_rounded : Icons.cloud_upload_rounded),
                  label: Text(isRetry ? l10n.retry : l10n.documentUpload),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _pickExpiry(BuildContext context) async {
    final bloc = context.read<DocumentsBloc>();
    final today = getIt<Clock>().now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.expiresAt ?? DateTime(today.year + 1, today.month, today.day),
      firstDate: tomorrow,
      lastDate: DateTime(today.year + 20),
      helpText: context.l10n.documentExpiryLabel,
    );
    if (picked != null) bloc.add(DocumentExpiryChanged(type, picked));
  }
}

class _SourceButtons extends StatelessWidget {
  const _SourceButtons({required this.type, required this.replacing});

  final DocumentType type;
  final bool replacing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<DocumentsBloc>();
    void pick(DocumentSource source) => bloc.add(DocumentPickRequested(type, source));

    Widget button(DocumentSource source, IconData icon, String label) => Expanded(
      child: OutlinedButton.icon(
        key: ValueKey('pick-${type.apiValue}-${source.name}'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        ),
        onPressed: () => pick(source),
        icon: Icon(icon, size: 20),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          replacing ? l10n.documentReplace : l10n.documentChoose,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            button(DocumentSource.camera, Icons.photo_camera_outlined, l10n.documentSourceCamera),
            const SizedBox(width: 8),
            button(DocumentSource.gallery, Icons.photo_library_outlined, l10n.documentSourceGallery),
            const SizedBox(width: 8),
            button(DocumentSource.file, Icons.picture_as_pdf_outlined, l10n.documentSourceFile),
          ],
        ),
      ],
    );
  }
}

/// Expiry is a calendar date (the server stores midnight UTC), so it is
/// formatted from its own fields — converting to local time could shift it
/// by a day.
String _formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(date);
