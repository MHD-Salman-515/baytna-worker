import 'package:baytna_worker/core/config/app_config.dart';
import 'package:baytna_worker/core/localization/locale_cubit.dart';
import 'package:baytna_worker/core/network/accept_language_interceptor.dart';
import 'package:baytna_worker/core/network/dio_factory.dart';
import 'package:baytna_worker/core/network/server_status.dart';
import 'package:baytna_worker/core/network/token_refresher.dart';
import 'package:baytna_worker/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  @Named(refreshDioName)
  Dio refreshDio(AppConfig config, ServerStatus status) =>
      DioFactory.createRefreshDio(config, status);

  @lazySingleton
  Dio apiDio(
    AppConfig config,
    ServerStatus status,
    TokenStorage storage,
    TokenRefresher refresher,
    LocaleCubit locale,
  ) => DioFactory.createApiDio(
    config: config,
    status: status,
    storage: storage,
    refresher: refresher,
    extra: [AcceptLanguageInterceptor(() => locale.state.languageCode)],
  );
}
