import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import '../../models/auth/auth_model.dart';
import '../../../user/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuth(UserModel auth);
  Future<UserModel?> getCachedAuth();
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const kCachedAuth = 'kCachedAuth';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheAuth(UserModel auth) =>
      secureStorage.write(key: kCachedAuth, value: json.encode(auth.toJson()));

  @override
  Future<UserModel?> getCachedAuth() async {
    final jsonString = await secureStorage.read(key: kCachedAuth);

    if (jsonString != null) {
      try {
        return UserModel.fromJson(jsonDecode(jsonString));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> logout() => secureStorage.delete(key: kCachedAuth);
}
