import 'dart:convert';

import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Caches the signed-in user (it contains the phone number, so it lives in
/// secure storage alongside the tokens).
@lazySingleton
class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;
  static const _userKey = 'auth.user';

  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(asJson(jsonDecode(raw)));
    } on Object catch (_) {
      await clearUser(); // stale schema from an older build
      return null;
    }
  }

  Future<void> saveUser(UserModel user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  Future<void> clearUser() => _storage.delete(key: _userKey);
}
