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

  Future<BaseResponse> fetchProfile(String userId) async {
    try {
      String? token = await SecureStorageService.getToken();

      // Function to make the API call
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

      // Attempt to fetch Karyawan profile
      final response = await makeApiCall("api/karyawan/profil");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        Karyawan karyawan = Karyawan.fromJson(responseBody['data']);

        return BaseResponse<Karyawan>(
          status: responseBody['status'],
          message: responseBody['message'],
          data: karyawan,
        );
      } else if (response.statusCode == 404) {
        // Attempt to fetch Admin profile if Karyawan profile is not found
        final adminResponse = await makeApiCall("api/admin/profil");
        final adminResponseBody = json.decode(adminResponse.body);
        Mitra mitra = Mitra.fromJson(adminResponseBody['data']);
        return BaseResponse<Mitra>(
          status: adminResponseBody['status'],
          message: adminResponseBody['message'],
          data: mitra,
        );
      } else {
        // Handle any other non-200 responses
        return _handleResponse(response);
      }
    } catch (e) {
      return BaseResponse<Karyawan>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
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
