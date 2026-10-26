import 'package:baytna_worker/core/config/app_config.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AppModule {
  @singleton
  AppConfig get config => AppConfig.fromEnvironment();
}
