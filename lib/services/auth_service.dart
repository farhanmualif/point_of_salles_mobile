import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/login_model.dart';
import 'package:point_of_salles_mobile_app/services/api_exception.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String? baseUrl = dotenv.env['API_URL'];

  Future<BaseResponse<UserData>> signin(String email, String password) async {
    try {
      final response = await http.post(Uri.parse("${baseUrl!}/api/signin"),
          body: json.encode({"email": email, "password": password}),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          });

      final responseBody = json.decode(response.body);
      final loginResponse =
          BaseResponse.fromJson(responseBody, UserData.fromJson);

      if (loginResponse.data != null && loginResponse.data!.akses == "1") {
        return BaseResponse(
          status: false,
          message: 'Akses ditolak',
          errors: {
            'access': [
              'Anda tidak memiliki hak akses untuk menggunakan aplikasi ini'
            ],
          },
        );
      }

      if (response.statusCode == 200 && loginResponse.data != null) {
        await SecureStorageService.saveToken(loginResponse.data!.token);
        await SecureStorageService.saveUserData(
          json.encode({
            'nama': loginResponse.data!.nama,
            'username': loginResponse.data!.username,
            'email': loginResponse.data!.email,
            'akses': loginResponse.data!.akses,
            'aksesName': loginResponse.data!.aksesName,
          }),
        );
      }

      return loginResponse;
    } on TimeoutException {
      return BaseResponse(
        status: false,
        message: 'Request timeout. Silakan coba lagi.',
        errors: {
          'timeout': ['Koneksi terlalu lama, silakan periksa internet Anda.'],
        },
      );
    } on ApiException catch (e) {
      return BaseResponse(
        status: false,
        message: e.message,
        errors: {
          'api': [e.message],
        },
      );
    } catch (e) {
      return BaseResponse(
        status: false,
        message: 'Terjadi kesalahan',
        errors: {
          'unknown': [e.toString()],
        },
      );
    }
  }

  Future<bool> checkAuth() async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.get(
          Uri.parse("${baseUrl!}/api/cek-autentikasi"),
          headers: {"Authorization": "Bearer $token"});

      final resBody = BaseResponse.fromJson(json.decode(response.body));
      debugPrint("message: ${resBody.message}");
      return response.statusCode == 200 && resBody.status;
    } on TimeoutException {
      return false;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<BaseResponse> logout() async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.post(
        Uri.parse("${baseUrl!}/api/logout"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      final responseBody = json.decode(response.body);
      final logoutResponse = BaseResponse.fromJson(responseBody);

      if (response.statusCode == 200 && logoutResponse.status) {
        // Hapus token dan data user dari secure storage
        await SecureStorageService.clearAll();
      }

      return logoutResponse;
    } on TimeoutException {
      return BaseResponse(
        status: false,
        message: 'Request timeout. Silakan coba lagi.',
        errors: {
          'timeout': ['Koneksi terlalu lama, silakan periksa internet Anda.'],
        },
      );
    } on ApiException catch (e) {
      return BaseResponse(
        status: false,
        message: e.message,
        errors: {
          'api': [e.message],
        },
      );
    } catch (e) {
      return BaseResponse(
        status: false,
        message: 'Terjadi kesalahan saat logout',
        errors: {
          'unknown': [e.toString()],
        },
      );
    }
  }

  Future<int> getUserAccess() async {
    final userData = await SecureStorageService.getUserData();
    if (userData != null) {
      final data = json.decode(userData);
      return int.parse(data['akses'] ?? '3');
    }
    return 3; // default ke user biasa
  }
}
