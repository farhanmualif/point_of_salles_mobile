import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';

class ProductService {
  final String? baseUrl = dotenv.env['API_URL'];

  Future<BaseResponse<List<Product>>> fetchProducts() async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.get(
        Uri.parse("${baseUrl!}/api/produk"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        List<Product> products = (responseBody['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();

        return BaseResponse<List<Product>>(
          status: responseBody['status'],
          message: responseBody['message'],
          data: products,
        );
      } else {
        // Handle non-200 responses
        final responseBody = json.decode(response.body);
        return BaseResponse<List<Product>>(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      }
    } catch (e) {
      return BaseResponse<List<Product>>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<Product>> createProduct({
    required String namaProduk,
    required String kategori,
    required int harga,
    required int qty,
    File? foto,
  }) async {
    try {
      // Validasi kategori
      if (kategori != 'Makanan' && kategori != 'Minuman') {
        return BaseResponse<Product>(
          status: false,
          message: 'Kategori hanya boleh Makanan atau Minuman',
        );
      }

      String? token = await SecureStorageService.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl!}/api/produk"),
      );

      // Tambahkan headers
      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      // Tambahkan fields
      request.fields['namaProduk'] = namaProduk;
      request.fields['kategori'] = kategori;
      request.fields['harga'] = harga.toString();
      request.fields['stok'] = qty.toString(); // Tambahkan qty

      // Tambahkan foto jika ada
      if (foto != null) {
        var multipartFile =
            await http.MultipartFile.fromPath('foto', foto.path);
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = json.decode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BaseResponse<Product>(
          status: decodedResponse['status'],
          message: decodedResponse['message'],
        );
      } else {
        return BaseResponse<Product>(
          status: decodedResponse['status'],
          message: decodedResponse['message'],
        );
      }
    } catch (e) {
      return BaseResponse<Product>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<Product>> updateProductStatus({
    required String productId,
  }) async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.put(
        Uri.parse("${baseUrl!}/api/produk/$productId/status"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      final decodedResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return BaseResponse<Product>(
          status: decodedResponse['status'],
          message: decodedResponse['message'],
        );
      } else {
        return BaseResponse<Product>(
          status: false,
          message: decodedResponse['message'] ?? 'Gagal mengubah status produk',
        );
      }
    } catch (e) {
      return BaseResponse<Product>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<Product>> getProductById(String productId) async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.get(
        Uri.parse("${baseUrl!}/api/produk/$productId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse<Product>(
          status: true,
          message: decodedResponse['message'],
          data: Product.fromJson(decodedResponse['data']),
        );
      } else {
        return BaseResponse<Product>(
          status: false,
          message:
              decodedResponse['message'] ?? 'Gagal mengambil detail produk',
        );
      }
    } catch (e) {
      return BaseResponse<Product>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<dynamic>> addProductStock({
    required String productId,
    required int qty,
  }) async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.put(
        Uri.parse("${baseUrl!}/api/produk/stok/add"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "produkId": productId,
          "qty": qty,
        }),
      );

      print(response.body);
      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse<dynamic>(
          status: decodedResponse['status'],
          message: decodedResponse['message'],
          data: decodedResponse['data'],
        );
      } else {
        return BaseResponse<dynamic>(
          status: decodedResponse['status'],
          message: decodedResponse['message'] ?? 'Gagal menambah stok produk',
        );
      }
    } catch (e) {
      return BaseResponse<dynamic>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<Product>> updateProduct({
    required String productId,
    required String namaProduk,
    required String kategori,
    required int harga,
    File? foto,
  }) async {
    try {
      String? token = await SecureStorageService.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl!}/api/produk/$productId"),
      );

      // Tambahkan headers
      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      // Tambahkan fields
      request.fields['namaProduk'] = namaProduk;
      request.fields['kategori'] = kategori;
      request.fields['harga'] = harga.toString();
      request.fields['_method'] = 'PUT';

      // Tambahkan file jika ada
      if (foto != null) {
        var multipartFile =
            await http.MultipartFile.fromPath('foto', foto.path);
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        return BaseResponse<Product>(
          status: decodedResponse['status'],
          message: decodedResponse['message'],
        );
      } else {
        return BaseResponse<Product>(
          status: decodedResponse['status'],
          message:
              decodedResponse['message'] ?? 'Gagal memperbarui data produk',
        );
      }
    } catch (e) {
      return BaseResponse<Product>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
