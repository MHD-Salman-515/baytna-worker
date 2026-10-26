import 'package:flutter/foundation.dart';

/// Deployment environment, selected at build time with
/// `--dart-define=APP_ENV=staging|production` (defaults to staging).
enum AppEnvironment {
  staging,
  production;

  static AppEnvironment fromName(String name) => AppEnvironment.values
      .firstWhere((e) => e.name == name, orElse: () => AppEnvironment.staging);
}

/// Immutable, build-time configuration. Nothing in here is secret; secrets
/// (the dev OTP key) live in `secrets.json`, see `lib/core/dev/dev_otp.dart`.
@immutable
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 90),
    this.sendTimeout = const Duration(seconds: 30),
    this.slowRequestThreshold = const Duration(seconds: 4),
  });

  factory AppConfig.fromEnvironment() {
    const envName = String.fromEnvironment('APP_ENV', defaultValue: 'staging');
    const override = String.fromEnvironment('API_BASE_URL');
    final env = AppEnvironment.fromName(envName);
    final baseUrl = override.isNotEmpty ? override : _defaultBaseUrls[env];
    if (baseUrl == null) {
      throw StateError(
        'No API base URL for $env. Pass --dart-define=API_BASE_URL=<url>.',
      );
    }
    return AppConfig(environment: env, apiBaseUrl: baseUrl);
  }

  /// Production has no URL yet; it must be supplied via API_BASE_URL until
  /// it exists, so a production build can never silently hit staging.
  static const _defaultBaseUrls = <AppEnvironment, String>{
    AppEnvironment.staging: 'https://baytna-api-z7v9.onrender.com/api/v1',
  };

  final AppEnvironment environment;
  final String apiBaseUrl;

  /// Generous on purpose: the staging server (Render free tier) sleeps when
  /// idle and the first request after that can take 30–60 seconds.
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// After this long without a response, the UI shows "server waking up".
  final Duration slowRequestThreshold;

  bool get isStaging => environment == AppEnvironment.staging;
}
