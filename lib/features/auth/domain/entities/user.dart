import 'package:equatable/equatable.dart';

/// The signed-in account, as returned by POST /auth/otp/verify (`user`) and
/// GET /auth/me.
class User extends Equatable {
  const User({
    required this.id,
    required this.phone,
    required this.countryId,
    this.cityId,
    this.roles = const [],
    this.status,
    this.locale,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;

  /// E.164, e.g. +963911111111.
  final String phone;
  final String countryId;

  /// Null until the user picks a city.
  final String? cityId;

  /// Backend role names from the DATABASE, e.g. ["CUSTOMER", "WORKER"]. The
  /// server authorizes from the roles in the access token instead, which lag
  /// behind until the token is refreshed (see WorkerRepositoryImpl.apply).
  final List<String> roles;

  /// Account status, e.g. "ACTIVE".
  final String? status;

  /// Preferred language stored on the server ('ar' | 'en').
  final String? locale;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  bool get isCustomer => roles.contains(UserRoles.customer);

  /// Has applied to work. Says NOTHING about being allowed to work — only
  /// `WorkerProfile.verificationStatus == approved` does.
  bool get hasWorkerRole => roles.contains(UserRoles.worker);

  @override
  List<Object?> get props => [id, phone, countryId, cityId, roles, status, locale, createdAt, lastLoginAt];
}

abstract final class UserRoles {
  static const customer = 'CUSTOMER';
  static const worker = 'WORKER';
}
