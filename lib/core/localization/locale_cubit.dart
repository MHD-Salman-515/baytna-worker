import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// App language. Arabic by default; the user's choice is persisted.
///
/// A Cubit rather than a Bloc: its state is a single value with one
/// operation, so events would add ceremony without adding clarity. Feature
/// state machines use full Blocs (see README → Conventions).
@lazySingleton
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage) : super(AppLocales.fallback);

  final FlutterSecureStorage _storage;
  static const _key = 'app.locale';

  Future<void> load() async {
    final code = await _storage.read(key: _key);
    if (code != null) emit(AppLocales.fromCode(code));
  }

  Future<void> setLocale(Locale locale) async {
    emit(AppLocales.fromCode(locale.languageCode));
    await _storage.write(key: _key, value: state.languageCode);
  }

  Future<void> toggle() => setLocale(
    state.languageCode == 'ar' ? AppLocales.english : AppLocales.arabic,
  );
}
