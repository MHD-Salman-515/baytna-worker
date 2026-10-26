import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A backend-provided `{ "ar": "...", "en": "..." }` object.
///
/// Models keep these as-is; resolve them at the last moment (in the widget)
/// with `context.localize(text)` so a language switch re-renders correctly.
class LocalizedText extends Equatable {
  const LocalizedText({required this.ar, required this.en});

  /// Tolerates a missing language or a plain string, so one bad record from
  /// the backend degrades to the other language instead of crashing.
  factory LocalizedText.fromJson(Object? json) {
    if (json is String) return LocalizedText(ar: json, en: json);
    if (json is Map) {
      final ar = json['ar'] as String?;
      final en = json['en'] as String?;
      return LocalizedText(ar: ar ?? en ?? '', en: en ?? ar ?? '');
    }
    return const LocalizedText(ar: '', en: '');
  }

  final String ar;
  final String en;

  /// Exact language match, then Arabic (the primary language), then English.
  String resolve(Locale locale) {
    final preferred = switch (locale.languageCode) {
      'en' => en,
      _ => ar,
    };
    if (preferred.isNotEmpty) return preferred;
    return ar.isNotEmpty ? ar : en;
  }

  Map<String, String> toJson() => {'ar': ar, 'en': en};

  @override
  List<Object?> get props => [ar, en];
}

extension LocalizedTextX on BuildContext {
  String localize(LocalizedText text) =>
      text.resolve(Localizations.maybeLocaleOf(this) ?? AppLocales.fallback);
}
