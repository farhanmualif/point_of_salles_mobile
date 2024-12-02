// karyawan_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/profile.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';

class KaryawanService {
  final String? baseUrl = dotenv.env['API_URL'];

  Future<BaseResponse> fetchProfile(String access) async {
    try {
      String? token = await SecureStorageService.getToken();

      // Fungsi helper untuk panggilan API
      Future<http.Response> makeApiCall(String endpoint) {
        return http.get(
          Uri.parse("${baseUrl!}/$endpoint"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );
      }

      // Handle berdasarkan tipe akses
      switch (access) {
        case '2':
          return await _handleAdminProfile(makeApiCall);
        case '3':
          return await _handleKaryawanProfile(makeApiCall);
        default:
          return BaseResponse<Mitra>(
            status: false,
            message: "Terjadi kesalahan saat mengambil profil",
          );
      }
    } catch (e) {
      return BaseResponse<dynamic>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // Handler untuk profil karyawan
  Future<BaseResponse> _handleKaryawanProfile(
      Future<http.Response> Function(String) makeApiCall) async {
    final response = await makeApiCall("api/karyawan/profil");
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return BaseResponse<Karyawan>(
        status: responseBody['status'],
        message: responseBody['message'],
        data: Karyawan.fromJson(responseBody['data']),
      );
    }
    return _handleResponse(response);
  }

  // Handler untuk profil kasir
  Future<BaseResponse> _handleAdminProfile(
      Future<http.Response> Function(String) makeApiCall) async {
    final response = await makeApiCall("api/admin/profil");
    debugPrint("response: ${response.body}");
    final adminResponseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return BaseResponse<Mitra>(
        status: adminResponseBody['status'],
        message: adminResponseBody['message'],
        data: Mitra.fromJson(adminResponseBody['data']),
      );
    }
    return _handleResponse(response);
  }

  // Helper function to handle the response and return BaseResponse
  BaseResponse<Karyawan> _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    return BaseResponse<Karyawan>(
      status: responseBody['status'],
      message: responseBody['message'],
    );
  }

  Future<BaseResponse> updateProfile({
    required String karyawanId,
    required String nama,
    required String email,
    required String alamat,
    required String noTelp,
  }) async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.put(
        Uri.parse("${baseUrl!}/api/karyawan/profil/$karyawanId/ubah"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "nama": nama,
          "email": email,
          "alamat": alamat,
          "no_telp": noTelp,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      } else {
        return BaseResponse(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      }
    } catch (e) {
      return BaseResponse(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
