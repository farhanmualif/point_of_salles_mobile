import 'package:point_of_salles_mobile_app/models/cart_detail_model.dart';

class Cart {
  final String id;
  final String userId;
  final String tanggal;
  int totalHarga;
  final String mitraId;
  final String status;
  final List<CartDetail> details; // List of CartDetail

  Cart({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.totalHarga,
    required this.mitraId,
    required this.status,
    required this.details,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['userId'],
      tanggal: json['tanggal'],
      totalHarga: json['totalHarga'],
      mitraId: json['mitraId'],
      status: json['status'],
      details: (json['keranjang_details'] as List)
          .map((item) => CartDetail.fromJson(item))
          .toList(),
    );
  }
}