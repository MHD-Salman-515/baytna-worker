import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:flutter/material.dart';

/// Asks why (the backend requires a reason) and returns it, or null if she
/// backed out. Common reasons are one tap; "other" lets her type. [notice] is
/// a consequence to state before she commits.
Future<String?> askForReason(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required List<String> presets,
  String? notice,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _ReasonSheet(title: title, confirmLabel: confirmLabel, presets: presets, notice: notice),
);

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({required this.title, required this.confirmLabel, required this.presets, this.notice});

  final String title;
  final String confirmLabel;
  final List<String> presets;
  final String? notice;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
  String? _preset;
  String _typed = '';

  String get _reason => (_preset ?? _typed).trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          if (widget.notice != null) ...[
            const SizedBox(height: 8),
            Text(widget.notice!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, preset) in widget.presets.indexed)
                ChoiceChip(
                  key: ValueKey('reason-$i'),
                  label: Text(preset),
                  selected: _preset == preset,
                  onSelected: (on) => setState(() => _preset = on ? preset : null),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('reason-text'),
            enabled: _preset == null,
            maxLength: 200,
            decoration: InputDecoration(labelText: context.l10n.reasonOther),
            onChanged: (v) => setState(() => _typed = v),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey('reason-confirm'),
            onPressed: _reason.isEmpty ? null : () => Navigator.of(context).pop(_reason),
            child: Text(widget.confirmLabel),
          ),
        ],
      ),
    );
  }
}
