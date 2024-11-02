// services/transaksi_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/transaction.dart';
import 'package:point_of_salles_mobile_app/services/api_exception.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';

class TransactionService {
  final String? baseUrl = dotenv.env['API_URL'];

  Future<BaseResponse<Transaction>> getPendingTransaction() async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.get(
        Uri.parse("${baseUrl!}/api/transaksi/pending"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      final responseBody = json.decode(response.body);
      return BaseResponse.fromJson(responseBody, Transaction.fromJson);
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
}
