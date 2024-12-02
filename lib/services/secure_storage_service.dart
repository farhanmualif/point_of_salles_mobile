import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  // Menyimpan token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Mengambil token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Mengecek apakah token ada
  static Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: 'token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error reading token: $e');
      return false;
    }
  }

  // Menyimpan user data (dalam bentuk JSON string)
  static Future<void> saveUserData(String jsonData) async {
    await _storage.write(key: _userDataKey, value: jsonData);
  }

  // Mengambil user data
  static Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  // Menghapus semua data (untuk logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

   static Future<String?> getAccessLevel() async {
    try {
      final userDataJson = await SecureStorageService.getUserData();
      if (userDataJson != null) {
        final userData = json.decode(userDataJson);
        return userData['akses'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting access level: $e');
      return null;
    }
  }

  static bool hasAdminAccess(String? accessLevel) {
    return accessLevel == '1' || accessLevel == '2';
  }

  static bool hasOwnerAccess(String? accessLevel) {
    return accessLevel == '1';
  }

  static bool hasKasirAccess(String? accessLevel) {
    return accessLevel == '3';
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }
}
