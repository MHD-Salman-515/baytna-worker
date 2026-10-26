import 'package:baytna_worker/core/widgets/language_toggle_button.dart';
import 'package:flutter/material.dart';

/// Standard page: app bar (automatic, RTL-aware back button + language
/// toggle), a title/subtitle header, and content constrained to a readable
/// width on wide screens (Chrome).
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.title,
    required this.body,
    this.subtitle,
    this.appBarTitle,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? appBarTitle;
  final List<Widget> actions;
  final Widget body;

  static const double maxContentWidth = 480;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle == null ? null : Text(appBarTitle!),
        actions: [...actions, const LanguageToggleButton(), const SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
