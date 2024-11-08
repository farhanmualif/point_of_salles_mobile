import 'package:point_of_salles_mobile_app/models/detail_transaction.dart';
import 'package:point_of_salles_mobile_app/models/ewallet_payment_status.dart';
import 'package:point_of_salles_mobile_app/models/va_payment_status.dart';

class Transaction {
  final String id;
  final String invoiceId;
  final String xenditId;
  final String namaUser;
  final String? nomorHpAktif;
  final int totalHarga;
  final String usernameKasir;
  final String mitraId;
  final String namaMitra;
  final String tipeTransaksi;
  final String? statusOrder;
  final String tanggalOrder;
  final String? tanggalBayar;
  final String? paymentChannel;
  final VAPaymentStatus? vaPaymentStatus;
  final EWalletPaymentStatus? ewalletPaymentStatus;
  final List<DetailTransaction> transaksiDetail;

  Transaction({
    required this.id,
    required this.invoiceId,
    required this.xenditId,
    required this.namaUser,
    this.nomorHpAktif,
    required this.totalHarga,
    required this.usernameKasir,
    required this.mitraId,
    required this.namaMitra,
    required this.tipeTransaksi,
    this.statusOrder,
    required this.tanggalOrder,
    this.tanggalBayar,
    this.paymentChannel,
    this.vaPaymentStatus,
    this.ewalletPaymentStatus,
    required this.transaksiDetail,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      invoiceId: json['invoiceId'],
      xenditId: json['xenditId'],
      namaUser: json['namaUser'],
      nomorHpAktif: json['nomorHpAktif'],
      totalHarga: json['totalHarga'],
      usernameKasir: json['usernameKasir'],
      mitraId: json['mitraId'],
      namaMitra: json['namaMitra'],
      tipeTransaksi: json['tipeTransaksi'],
      statusOrder: json['statusOrder'],
      tanggalOrder: json['tanggalOrder'],
      tanggalBayar: json['tanggalBayar'],
      paymentChannel: json['paymentChannel'],
      vaPaymentStatus: json['va_payment_status'] != null
          ? VAPaymentStatus.fromJson(json['va_payment_status'])
          : null,
      ewalletPaymentStatus: json['ewallet_payment_status'] != null
          ? EWalletPaymentStatus.fromJson(json['ewallet_payment_status'])
          : null,
      transaksiDetail: (json['transaksi_detail'] as List)
          .map((detail) => DetailTransaction.fromJson(detail))
          .toList(),
    );
  } 
}

// models/transaction_history.dart
class TransactionHistory {
  final String invoiceId;
  final String xenditId;
  final double totalHarga;
  final String namaUser;
  final DateTime tanggal;
  final List<TransactionItemHistory> items;

  TransactionHistory({
    required this.invoiceId,
    required this.xenditId,
    required this.totalHarga,
    required this.namaUser,
    required this.tanggal,
    required this.items,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      invoiceId: json['invoiceId'] ?? '',
      xenditId: json['xenditId'] ?? '',
      totalHarga: (json['totalHarga'] ?? 0).toDouble(),
      namaUser: json['namaUser'] ?? '',
      tanggal:
          DateTime.parse(json['tanggal'] ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => TransactionItemHistory.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'invoiceId': invoiceId,
        'xenditId': xenditId,
        'totalHarga': totalHarga,
        'namaUser': namaUser,
        'tanggal': tanggal.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class TransactionItemHistory {
  final String namaProduk;
  final String kategori;
  final double hargaProduk;
  final int qtyProduk;
  final String? fotoProduk;
  final double subtotal;

  TransactionItemHistory({
    required this.namaProduk,
    required this.kategori,
    required this.hargaProduk,
    required this.qtyProduk,
    this.fotoProduk,
    required this.subtotal,
  });

  factory TransactionItemHistory.fromJson(Map<String, dynamic> json) {
    return TransactionItemHistory(
      namaProduk: json['namaProduk'] ?? '',
      kategori: json['kategori'] ?? '',
      hargaProduk: (json['hargaProduk'] ?? 0).toDouble(),
      qtyProduk: json['qtyProduk'] ?? 0,
      fotoProduk: json['fotoProduk'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'namaProduk': namaProduk,
        'kategori': kategori,
        'hargaProduk': hargaProduk,
        'qtyProduk': qtyProduk,
        'fotoProduk': fotoProduk,
        'subtotal': subtotal,
      };
}
