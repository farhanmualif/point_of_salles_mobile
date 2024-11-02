import 'dart:convert';
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
}
