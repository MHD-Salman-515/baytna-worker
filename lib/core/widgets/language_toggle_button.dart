import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows the *other* language's name in that language ("English" / "العربية").
/// Server sync while signed in is handled centrally in `app.dart`.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.read<LocaleCubit>().toggle(),
      icon: const Icon(Icons.translate_rounded, size: 20),
      label: Text(context.l10n.switchLanguage),
    );
  }
}
