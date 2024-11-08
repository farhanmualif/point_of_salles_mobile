// services/transaksi_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
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

      debugPrint("pending transction ${response.body}");
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

  Future<BaseResponse<List<TransactionHistory>>> getTransactionHistory() async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.get(
        Uri.parse("${baseUrl!}/api/transaksi/riwayat"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse<List<TransactionHistory>>(
          status: responseBody['status'] ?? false,
          message: responseBody['message'] ?? '',
          data: (responseBody['data'] as List<dynamic>?)
                  ?.map((item) => TransactionHistory.fromJson(item))
                  .toList() ??
              [],
        );
      } else {
        throw ApiException(
          message: responseBody['message'] ?? 'Terjadi kesalahan pada server',
        );
      }
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
