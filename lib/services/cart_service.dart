import 'dart:convert';

import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/cart_detail_model.dart';
import 'package:point_of_salles_mobile_app/models/cart_model.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class CartService {
  final String? baseUrl = dotenv.env['API_URL'];
  Future<BaseResponse<String>> addToCart(String produkId, int qtyProduk) async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.post(
        Uri.parse("${baseUrl!}/api/keranjang/$produkId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "qtyProduk": qtyProduk,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse<String>(
          status: responseBody['status'],
          message: responseBody['message'],
          data: responseBody['data']?.toString(),
        );
      } else {
        return BaseResponse<String>(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      }
    } catch (e) {
      return BaseResponse<String>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<String>> postCart(List<Product> products) async {
    try {
      String? token = await SecureStorageService.getToken();
      String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // Perbaikan pada mapping produk
      final List<Map<String, dynamic>> productMaps = products
          .map((product) => {"id": product.id, "qty": product.count})
          .toList(); // Perlu ditambahkan .toList()

      final response = await http.post(
        Uri.parse("${baseUrl!}/api/keranjang"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "tanggal": formattedDate,
          "produk":
              productMaps // Menggunakan hasil mapping yang sudah dikonversi ke List
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return BaseResponse<String>(
          status: responseBody['status'],
          message: responseBody['message'],
          data: responseBody['data']?.toString(),
        );
      } else {
        // Handle error status code selain 200
        final responseBody = json.decode(response.body);
        return BaseResponse<String>(
          status: false,
          message: responseBody['message'] ?? 'Failed to update cart',
        );
      }
    } catch (e) {
      return BaseResponse<String>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<int> getCartQtyByProductId(String produkId) async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.get(
        Uri.parse("${baseUrl!}/api/keranjang/$produkId/produk"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // Menghandle kasus dimana data ada
        if (responseBody['data'] != null) {
          final cartDetail = CartDetail.fromJson(responseBody['data']);
          return cartDetail.qty;
        } else {
          // Menghandle kasus dimana produk tidak ada di cart
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<BaseResponse<String>> updateCartQty(
      String idProduk, int newQty) async {
    try {
      String? token = await SecureStorageService.getToken();

      final response =
          await http.put(Uri.parse("${baseUrl!}/api/keranjang/$idProduk"),
              headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "Bearer $token",
              },
              body: json.encode({"qtyNew": newQty}));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse<String>(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      } else {
        return BaseResponse<String>(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      }
    } catch (e) {
      return BaseResponse<String>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<List<Cart>>> fetchCart() async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.get(
        Uri.parse("${baseUrl!}/api/keranjang"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final cartItems = (responseBody['data'] as List)
            .map((item) => Cart.fromJson(item))
            .toList();

        return BaseResponse<List<Cart>>(
          status: responseBody['status'],
          message: responseBody['message'],
          data: cartItems,
        );
      } else {
        return BaseResponse<List<Cart>>(
          status: false,
          message: responseBody['message'],
        );
      }
    } catch (e) {
      return BaseResponse<List<Cart>>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse> delete() async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.delete(
        Uri.parse("${baseUrl!}/api/keranjang"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      } else {
        return BaseResponse<List<Cart>>(
          status: false,
          message: responseBody['message'],
        );
      }
    } catch (e) {
      return BaseResponse<List<Cart>>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<BaseResponse<Cart>> fetchDetail(String idDetail) async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.get(
        Uri.parse("${baseUrl!}/api/keranjang/$idDetail"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final cartItems = (responseBody['data'] as Cart);

        return BaseResponse<Cart>(
          status: responseBody['status'],
          message: responseBody['message'],
          data: cartItems,
        );
      } else {
        return BaseResponse(
          status: false,
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

  Future<BaseResponse<CartDetail>> fetchDetailByProdukId(
      String produkId) async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.get(
        Uri.parse("${baseUrl!}/api/keranjang/$produkId/produk"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // Menghandle kasus dimana data ada
        if (responseBody['data'] != null) {
          return BaseResponse<CartDetail>(
            status: true,
            message: responseBody['message'],
            data: CartDetail.fromJson(responseBody['data']),
          );
        } else {
          // Menghandle kasus dimana produk tidak ada di cart
          return BaseResponse<CartDetail>(
              status: true, message: responseBody['message']);
        }
      } else {
        return BaseResponse(
            status: false,
            message: responseBody['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      return BaseResponse(
          status: false, message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<BaseResponse> deleteById(String cartId) async {
    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.delete(
        Uri.parse("${baseUrl!}/api/keranjang/$cartId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      } else {
        return BaseResponse(
          status: false,
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

  Future<BaseResponse<String>> deleteProductFromCart(String keranjangId, String produkId) async {
    try {
      String? token = await SecureStorageService.getToken();
      final response = await http.delete(
        Uri.parse("${baseUrl!}/api/keranjang/$keranjangId/produk/$produkId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return BaseResponse<String>(
          status: responseBody['status'],
          message: responseBody['message'],
        );
      } else {
        return BaseResponse<String>(
          status: false,
          message: responseBody['message'] ?? 'Gagal menghapus produk dari keranjang',
        );
      }
    } catch (e) {
      return BaseResponse<String>(
        status: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
