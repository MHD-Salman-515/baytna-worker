import 'package:baytna_worker/core/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

/// Registers everything annotated with `@injectable`, `@lazySingleton`,
/// `@singleton` or provided by a `@module`. Regenerate after changes with
/// `dart run build_runner build --delete-conflicting-outputs`.
@InjectableInit()
void configureDependencies() => getIt.init();
