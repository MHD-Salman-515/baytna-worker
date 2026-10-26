import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Shape verified against staging (POST /auth/otp/verify `user`, GET /auth/me):
///
/// ```json
/// { "isDeleted": false, "deletedAt": null, "phone": "+963911111111",
///   "countryId": "6adb…", "cityId": null, "roles": ["CUSTOMER"],
///   "status": "ACTIVE", "lastLoginAt": "2026-10-25T13:35:14.320Z",
///   "locale": "ar", "createdAt": "…", "updatedAt": "…", "id": "6ade…" }
/// ```
///
/// Server bookkeeping (isDeleted, deletedAt, updatedAt) is intentionally not
/// mapped.
@JsonSerializable()
class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  final String id;
  final String phone;
  final String countryId;
  final String? cityId;
  final List<String> roles;
  final String? status;
  final String? locale;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
    id: id,
    phone: phone,
    countryId: countryId,
    cityId: cityId,
    roles: roles,
    status: status,
    locale: locale,
    createdAt: createdAt,
    lastLoginAt: lastLoginAt,
  );
}
