import 'package:point_of_salles_mobile_app/models/product_model.dart';

class CartDetail {
  final String id;
  final String keranjangId;
  final String produkId;
  int qty;
  final int harga;
  final Product produk; // Assuming you have a Product model

  CartDetail({
    required this.id,
    required this.keranjangId,
    required this.produkId,
    required this.qty,
    required this.harga,
    required this.produk,
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'],
      keranjangId: json['keranjangId'],
      produkId: json['produkId'],
      qty: json['qty'],
      harga: json['harga'],
      produk: Product.fromJson(json['produk']), // Parse the product information
    );
  }
}
