// karyawan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/profile.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';

class KaryawanService {
  final String? baseUrl = dotenv.env['API_URL'];

  Future<BaseResponse<Karyawan>> fetchProfile(String userId) async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.get(
        Uri.parse("${baseUrl!}/api/karyawan/profil"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        Karyawan karyawan = Karyawan.fromJson(responseBody['data']);

        return BaseResponse<Karyawan>(
          status: responseBody['status'],
          message: responseBody['message'],
          data: karyawan,
        );
      } else {
        // Handle non-200 responses
        final responseBody = json.decode(response.body);
        return BaseResponse<Karyawan>(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      }
    } catch (e) {
      return BaseResponse<Karyawan>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
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
