import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';

class PaymentService {
  static final String? baseUrl = dotenv.env['API_URL'];

  // Validasi tipe pembayaran dan kode bank
  bool _isValidPaymentConfig(String? typePembayaran, String? codeBank) {
    if (typePembayaran == null || codeBank == null) return false;

    final validVABanks = ['MANDIRI', 'BNI', 'BRI', 'PERMATA'];
    final validEwallets = ['OVO', 'DANA', 'LINKAJA', 'SHOPEEPAY'];

    if (typePembayaran == 'VA') {
      return validVABanks.contains(codeBank);
    } else if (typePembayaran == 'EWALLET') {
      return validEwallets.contains(codeBank);
    }

    return false;
  }

  Future<BaseResponse<Map<String, dynamic>>> createPayment({
    required String customerName,
    required String paymentMethod,
    String? typePembayaran,
    String? codeBank,
    required String phoneNumber,
  }) async {
    // Validasi nomor telepon
    if (!phoneNumber.startsWith('+62')) {
      phoneNumber =
          '+62${phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber}';
    }

    // Validasi konfigurasi pembayaran
    if (paymentMethod != 'CASH' &&
        !_isValidPaymentConfig(typePembayaran, codeBank)) {
      return BaseResponse<Map<String, dynamic>>(
        status: false,
        message: 'Konfigurasi pembayaran tidak valid',
        data: null,
      );
    }

    String finalPaymentMethod =
        paymentMethod == 'EWALLET' ? 'TRANSFER' : paymentMethod;

    String? token = await SecureStorageService.getToken();
    final Map<String, dynamic> requestBody = {
      "nama_customer": customerName,
      "metode_pembayaran": finalPaymentMethod,
      "phone_number": phoneNumber,
      "tunai": 20000,
      "success_redirect_url": "$baseUrl/xendit/ewallet/success",
      "failure_redirect_url": "$baseUrl/xendit/ewallet/failure",
    };

    if (paymentMethod != 'CASH') {
      requestBody["tipe_pembayaran"] = typePembayaran;
      requestBody["code_bank"] = codeBank;
    }

    try {
      final response = await http.post(
        Uri.parse("${baseUrl!}/api/transaksi/checkout"),
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseBody = json.decode(response.body);

      return BaseResponse<Map<String, dynamic>>(
        status: responseBody['status'],
        message: responseBody['message'],
        data: responseBody['data'],
      );
    } catch (e) {
      return BaseResponse<Map<String, dynamic>>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<BaseResponse<Map<String, dynamic>>> checkPaymentStatus({
    required String idTransaction,
  }) async {
    String? token = await SecureStorageService.getToken();

    try {
      final response = await http.get(
        Uri.parse("${baseUrl!}/api/transaksi/$idTransaction/status"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseBody = json.decode(response.body);

      return BaseResponse<Map<String, dynamic>>(
        status: responseBody['status'],
        message: responseBody['message'],
        data: responseBody['data'],
      );
    } catch (e) {
      return BaseResponse<Map<String, dynamic>>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<BaseResponse<Map<String, dynamic>>> simulatePayment({
    required String idTransaction,
    required String amount,
  }) async {
    String? token = await SecureStorageService.getToken();

    try {
      final response = await http.post(
        Uri.parse("${baseUrl!}/api/xendit/simulate-payment"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "external_id": idTransaction,
          "amount": amount,
        }),
      );

      final responseBody = json.decode(response.body);

      return BaseResponse<Map<String, dynamic>>(
        status: responseBody['status'],
        message: responseBody['message'],
        data: responseBody['data'],
      );
    } catch (e) {
      return BaseResponse<Map<String, dynamic>>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<BaseResponse<Map<String, dynamic>>> simulateVAPayment({
    required String externalId,
    required String amount,
  }) async {
    String? token = await SecureStorageService.getToken();

    try {
      final response = await http.post(
        Uri.parse("${baseUrl!}/api/simulate-va-payment/$externalId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          'amount': int.parse(amount),
        }),
      );

      final responseBody = json.decode(response.body);

      return BaseResponse<Map<String, dynamic>>(
        status: responseBody['status'],
        message: responseBody['message'],
        data: responseBody['data'],
      );
    } catch (e) {
      return BaseResponse<Map<String, dynamic>>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        data: null,
      );
    }
  }
}
