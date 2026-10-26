import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/features/documents/domain/document_failures.dart';
import 'package:baytna_worker/features/documents/domain/document_requirements.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:flutter/material.dart';

extension DocumentTypeLabel on DocumentType {
  String label(AppLocalizations l10n) => switch (this) {
    DocumentType.nationalIdFront => l10n.documentNationalIdFront,
    DocumentType.nationalIdBack => l10n.documentNationalIdBack,
    DocumentType.criminalRecord => l10n.documentCriminalRecord,
    DocumentType.profilePhoto || DocumentType.other || DocumentType.unknown => l10n.documentOther,
  };

  IconData get icon => switch (this) {
    DocumentType.nationalIdFront || DocumentType.nationalIdBack => Icons.badge_outlined,
    DocumentType.criminalRecord => Icons.gavel_rounded,
    DocumentType.profilePhoto || DocumentType.other || DocumentType.unknown => Icons.description_outlined,
  };
}

/// Localized copy for document failures, falling back to the generic ones.
String documentFailureMessage(Failure failure, AppLocalizations l10n) => switch (failure) {
  DocumentTooLarge() => l10n.documentTooLarge,
  DocumentTypeNotAllowed() => l10n.documentTypeNotAllowed,
  DocumentExpiryRequired() => l10n.documentExpiryRequired,
  DocumentDeletionLocked() => l10n.documentDeletionLocked,
  _ => failure.message(l10n),
};

/// PENDING / APPROVED / REJECTED (/ missing / expired) — always text plus
/// icon, never colour alone.
class RequirementBadge extends StatelessWidget {
  const RequirementBadge({required this.state, super.key});

  final RequirementState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (label, icon, fg, bg) = switch (state) {
      RequirementState.missing => (l10n.documentStateMissing, Icons.upload_file_rounded, scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
      RequirementState.pending => (l10n.documentStatePending, Icons.hourglass_top_rounded, scheme.onSecondaryContainer, scheme.secondaryContainer),
      RequirementState.approved => (l10n.documentStateApproved, Icons.check_circle_rounded, scheme.onPrimaryContainer, scheme.primaryContainer),
      RequirementState.rejected => (l10n.documentStateRejected, Icons.cancel_rounded, scheme.onErrorContainer, scheme.errorContainer),
      RequirementState.expired => (l10n.documentStateExpired, Icons.event_busy_rounded, scheme.onErrorContainer, scheme.errorContainer),
    };
    return StatusChip(label: label, icon: icon, foreground: fg, background: bg);
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
