// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:baytna_worker/core/config/app_config.dart' as _i1016;
import 'package:baytna_worker/core/di/app_module.dart' as _i764;
import 'package:baytna_worker/core/localization/locale_cubit.dart' as _i30;
import 'package:baytna_worker/core/network/api_client.dart' as _i519;
import 'package:baytna_worker/core/network/network_module.dart' as _i726;
import 'package:baytna_worker/core/network/server_status.dart' as _i728;
import 'package:baytna_worker/core/network/session_events.dart' as _i863;
import 'package:baytna_worker/core/network/token_refresher.dart' as _i333;
import 'package:baytna_worker/core/router/app_router.dart' as _i1008;
import 'package:baytna_worker/core/storage/secure_token_storage.dart' as _i385;
import 'package:baytna_worker/core/storage/storage_module.dart' as _i370;
import 'package:baytna_worker/core/storage/token_storage.dart' as _i255;
import 'package:baytna_worker/core/utils/clock.dart' as _i204;
import 'package:baytna_worker/core/utils/ticker.dart' as _i230;
import 'package:baytna_worker/features/auth/data/datasources/auth_local_data_source.dart'
    as _i1064;
import 'package:baytna_worker/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i228;
import 'package:baytna_worker/features/auth/data/repositories/auth_repository_impl.dart'
    as _i211;
import 'package:baytna_worker/features/auth/domain/repositories/auth_repository.dart'
    as _i113;
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart'
    as _i51;
import 'package:baytna_worker/features/auth/presentation/bloc/countries/countries_bloc.dart'
    as _i317;
import 'package:baytna_worker/features/auth/presentation/bloc/otp/otp_bloc.dart'
    as _i450;
import 'package:baytna_worker/features/auth/presentation/bloc/phone/phone_bloc.dart'
    as _i94;
import 'package:baytna_worker/features/availability/data/datasources/availability_remote_data_source.dart'
    as _i129;
import 'package:baytna_worker/features/availability/data/repositories/availability_repository_impl.dart'
    as _i441;
import 'package:baytna_worker/features/availability/domain/repositories/availability_repository.dart'
    as _i41;
import 'package:baytna_worker/features/availability/presentation/bloc/availability/availability_bloc.dart'
    as _i328;
import 'package:baytna_worker/features/bookings/data/datasources/booking_remote_data_source.dart'
    as _i452;
import 'package:baytna_worker/features/bookings/data/repositories/booking_repository_impl.dart'
    as _i254;
import 'package:baytna_worker/features/bookings/domain/booking_context.dart'
    as _i285;
import 'package:baytna_worker/features/bookings/domain/repositories/booking_repository.dart'
    as _i783;
import 'package:baytna_worker/features/bookings/presentation/bloc/booking_detail/booking_detail_bloc.dart'
    as _i122;
import 'package:baytna_worker/features/bookings/presentation/bloc/bookings/bookings_bloc.dart'
    as _i968;
import 'package:baytna_worker/features/cities/data/datasources/city_remote_data_source.dart'
    as _i602;
import 'package:baytna_worker/features/cities/data/repositories/city_repository_impl.dart'
    as _i538;
import 'package:baytna_worker/features/cities/domain/repositories/city_repository.dart'
    as _i781;
import 'package:baytna_worker/features/countries/data/datasources/country_remote_data_source.dart'
    as _i899;
import 'package:baytna_worker/features/countries/data/repositories/country_repository_impl.dart'
    as _i66;
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart'
    as _i485;
import 'package:baytna_worker/features/documents/data/datasources/document_remote_data_source.dart'
    as _i415;
import 'package:baytna_worker/features/documents/data/datasources/platform_document_picker.dart'
    as _i562;
import 'package:baytna_worker/features/documents/data/repositories/document_repository_impl.dart'
    as _i1025;
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart'
    as _i274;
import 'package:baytna_worker/features/documents/presentation/bloc/documents/documents_bloc.dart'
    as _i1068;
import 'package:baytna_worker/features/offerings/data/datasources/offering_remote_data_source.dart'
    as _i890;
import 'package:baytna_worker/features/offerings/data/repositories/offering_repository_impl.dart'
    as _i942;
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart'
    as _i601;
import 'package:baytna_worker/features/offerings/presentation/bloc/offering_form/offering_form_bloc.dart'
    as _i176;
import 'package:baytna_worker/features/offerings/presentation/bloc/offerings/offerings_bloc.dart'
    as _i75;
import 'package:baytna_worker/features/onboarding/presentation/bloc/apply/apply_bloc.dart'
    as _i918;
import 'package:baytna_worker/features/onboarding/presentation/bloc/profile_form/profile_form_bloc.dart'
    as _i659;
import 'package:baytna_worker/features/onboarding/presentation/bloc/status/status_bloc.dart'
    as _i126;
import 'package:baytna_worker/features/wallet/data/datasources/wallet_remote_data_source.dart'
    as _i98;
import 'package:baytna_worker/features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i173;
import 'package:baytna_worker/features/wallet/domain/repositories/wallet_repository.dart'
    as _i6;
import 'package:baytna_worker/features/wallet/presentation/bloc/wallet/wallet_bloc.dart'
    as _i5;
import 'package:baytna_worker/features/worker/data/datasources/worker_remote_data_source.dart'
    as _i594;
import 'package:baytna_worker/features/worker/data/repositories/worker_repository_impl.dart'
    as _i724;
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart'
    as _i306;
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart'
    as _i690;
import 'package:baytna_worker/features/worker/presentation/bloc/availability_toggle/availability_toggle_cubit.dart'
    as _i715;
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart'
    as _i378;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final storageModule = _$StorageModule();
    final networkModule = _$NetworkModule();
    gh.factory<_i204.Clock>(() => const _i204.Clock());
    gh.factory<_i230.Ticker>(() => const _i230.Ticker());
    gh.singleton<_i1016.AppConfig>(() => appModule.config);
    gh.lazySingleton<_i728.ServerStatus>(() => _i728.ServerStatus());
    gh.lazySingleton<_i863.SessionEvents>(
      () => _i863.SessionEvents(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i30.LocaleCubit>(
      () => _i30.LocaleCubit(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i1064.AuthLocalDataSource>(
      () => _i1064.AuthLocalDataSource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i274.DocumentPicker>(
      () => _i562.PlatformDocumentPicker(),
    );
    gh.lazySingleton<_i255.TokenStorage>(
      () => _i385.SecureTokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.refreshDio(
        gh<_i1016.AppConfig>(),
        gh<_i728.ServerStatus>(),
      ),
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i333.TokenRefresher>(
      () => _i333.TokenRefresher(
        gh<_i255.TokenStorage>(),
        gh<_i361.Dio>(instanceName: 'refreshDio'),
        gh<_i863.SessionEvents>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.apiDio(
        gh<_i1016.AppConfig>(),
        gh<_i728.ServerStatus>(),
        gh<_i255.TokenStorage>(),
        gh<_i333.TokenRefresher>(),
        gh<_i30.LocaleCubit>(),
      ),
    );
    gh.lazySingleton<_i519.ApiClient>(() => _i519.ApiClient(gh<_i361.Dio>()));
    gh.lazySingleton<_i228.AuthRemoteDataSource>(
      () => _i228.AuthRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i129.AvailabilityRemoteDataSource>(
      () => _i129.AvailabilityRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i452.BookingRemoteDataSource>(
      () => _i452.BookingRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i602.CityRemoteDataSource>(
      () => _i602.CityRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i899.CountryRemoteDataSource>(
      () => _i899.CountryRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i415.DocumentRemoteDataSource>(
      () => _i415.DocumentRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i890.OfferingRemoteDataSource>(
      () => _i890.OfferingRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i98.WalletRemoteDataSource>(
      () => _i98.WalletRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i594.WorkerRemoteDataSource>(
      () => _i594.WorkerRemoteDataSource(gh<_i519.ApiClient>()),
    );
    gh.lazySingleton<_i113.AuthRepository>(
      () => _i211.AuthRepositoryImpl(
        gh<_i228.AuthRemoteDataSource>(),
        gh<_i1064.AuthLocalDataSource>(),
        gh<_i255.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i601.OfferingRepository>(
      () => _i942.OfferingRepositoryImpl(gh<_i890.OfferingRemoteDataSource>()),
    );
    gh.factory<_i75.OfferingsBloc>(
      () => _i75.OfferingsBloc(gh<_i601.OfferingRepository>()),
    );
    gh.factoryParam<_i450.OtpBloc, String, String>(
      (countryId, phone) => _i450.OtpBloc(
        gh<_i113.AuthRepository>(),
        gh<_i230.Ticker>(),
        countryId,
        phone,
      ),
    );
    gh.lazySingleton<_i51.AuthBloc>(
      () => _i51.AuthBloc(
        gh<_i113.AuthRepository>(),
        gh<_i30.LocaleCubit>(),
        gh<_i863.SessionEvents>(),
      ),
    );
    gh.lazySingleton<_i6.WalletRepository>(
      () => _i173.WalletRepositoryImpl(gh<_i98.WalletRemoteDataSource>()),
    );
    gh.lazySingleton<_i690.WorkerRepository>(
      () => _i724.WorkerRepositoryImpl(
        gh<_i594.WorkerRemoteDataSource>(),
        gh<_i255.TokenStorage>(),
        gh<_i333.TokenRefresher>(),
      ),
    );
    gh.lazySingleton<_i378.WorkerBloc>(
      () => _i378.WorkerBloc(gh<_i690.WorkerRepository>(), gh<_i51.AuthBloc>()),
    );
    gh.lazySingleton<_i485.CountryRepository>(
      () => _i66.CountryRepositoryImpl(gh<_i899.CountryRemoteDataSource>()),
    );
    gh.lazySingleton<_i783.BookingRepository>(
      () => _i254.BookingRepositoryImpl(gh<_i452.BookingRemoteDataSource>()),
    );
    gh.factory<_i918.ApplyBloc>(
      () => _i918.ApplyBloc(gh<_i690.WorkerRepository>()),
    );
    gh.factory<_i715.AvailabilityToggleCubit>(
      () => _i715.AvailabilityToggleCubit(gh<_i690.WorkerRepository>()),
    );
    gh.lazySingleton<_i274.DocumentRepository>(
      () => _i1025.DocumentRepositoryImpl(gh<_i415.DocumentRemoteDataSource>()),
    );
    gh.lazySingleton<_i41.AvailabilityRepository>(
      () => _i441.AvailabilityRepositoryImpl(
        gh<_i129.AvailabilityRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i781.CityRepository>(
      () => _i538.CityRepositoryImpl(gh<_i602.CityRemoteDataSource>()),
    );
    gh.factory<_i317.CountriesBloc>(
      () => _i317.CountriesBloc(gh<_i485.CountryRepository>()),
    );
    gh.factory<_i126.StatusBloc>(
      () => _i126.StatusBloc(
        gh<_i690.WorkerRepository>(),
        gh<_i274.DocumentRepository>(),
        gh<_i783.BookingRepository>(),
      ),
    );
    gh.factoryParam<_i328.AvailabilityBloc, String, dynamic>(
      (countryId, _) => _i328.AvailabilityBloc(
        gh<_i41.AvailabilityRepository>(),
        gh<_i485.CountryRepository>(),
        countryId,
      ),
    );
    gh.factoryParam<_i5.WalletBloc, String, dynamic>(
      (countryId, _) => _i5.WalletBloc(
        gh<_i6.WalletRepository>(),
        gh<_i485.CountryRepository>(),
        countryId,
      ),
    );
    gh.lazySingleton<_i1008.AppRouter>(
      () => _i1008.AppRouter(gh<_i51.AuthBloc>(), gh<_i378.WorkerBloc>()),
    );
    gh.factory<_i1068.DocumentsBloc>(
      () => _i1068.DocumentsBloc(
        gh<_i274.DocumentRepository>(),
        gh<_i274.DocumentPicker>(),
        gh<_i204.Clock>(),
      ),
    );
    gh.factoryParam<_i659.ProfileFormBloc, _i306.WorkerProfile, dynamic>(
      (profile, _) => _i659.ProfileFormBloc(
        gh<_i690.WorkerRepository>(),
        gh<_i781.CityRepository>(),
        profile,
      ),
    );
    gh.factoryParam<_i94.PhoneBloc, String, dynamic>(
      (_countryId, _) => _i94.PhoneBloc(
        gh<_i113.AuthRepository>(),
        gh<_i485.CountryRepository>(),
        _countryId,
      ),
    );
    gh.factoryParam<_i176.OfferingFormBloc, String, String?>(
      (countryId, offeringId) => _i176.OfferingFormBloc(
        gh<_i601.OfferingRepository>(),
        gh<_i485.CountryRepository>(),
        countryId,
        offeringId,
      ),
    );
    gh.lazySingleton<_i285.BookingContextLoader>(
      () => _i285.BookingContextLoader(
        gh<_i485.CountryRepository>(),
        gh<_i781.CityRepository>(),
        gh<_i601.OfferingRepository>(),
      ),
    );
    gh.factoryParam<_i122.BookingDetailBloc, String, String>(
      (id, countryId) => _i122.BookingDetailBloc(
        gh<_i783.BookingRepository>(),
        gh<_i285.BookingContextLoader>(),
        gh<_i601.OfferingRepository>(),
        gh<_i6.WalletRepository>(),
        id,
        countryId,
      ),
    );
    gh.factoryParam<_i968.BookingsBloc, String, dynamic>(
      (countryId, _) => _i968.BookingsBloc(
        gh<_i783.BookingRepository>(),
        gh<_i285.BookingContextLoader>(),
        countryId,
      ),
    );
    return this;
  }
}

class _$AppModule extends _i764.AppModule {}

class _$StorageModule extends _i370.StorageModule {}

class _$NetworkModule extends _i726.NetworkModule {}
