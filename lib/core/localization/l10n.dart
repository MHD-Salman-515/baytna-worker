import 'package:baytna_worker/core/localization/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:baytna_worker/core/localization/generated/app_localizations.dart';

/// Locales the app ships, in order of preference. Arabic is the default.
abstract final class AppLocales {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');
  static const Locale fallback = arabic;
  static const List<Locale> supported = [arabic, english];

  static Locale fromCode(String? code) => supported.firstWhere(
    (l) => l.languageCode == code,
    orElse: () => fallback,
  );
}

extension L10nX on BuildContext {
  /// `context.l10n.someKey` — the only way screens should get copy.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
