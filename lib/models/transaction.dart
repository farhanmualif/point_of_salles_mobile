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
  final String xendId;
  final int totalHarga;
  final String namaUser;
  final DateTime tanggal;
  final String? statusOrder;
  final String? noHp;
  final String? paymentChannel;
  final List<TransactionItem> items;

  TransactionHistory({
    required this.invoiceId,
    required this.xendId,
    required this.totalHarga,
    required this.namaUser,
    required this.tanggal,
    this.statusOrder,
    this.noHp,
    this.paymentChannel,
    required this.items,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>;

    final parsedItems = itemsList.map((item) {
      return TransactionItem.fromJson(item as Map<String, dynamic>);
    }).toList();

    return TransactionHistory(
      invoiceId: json['invoiceId'] as String,
      xendId: json['xendId'] as String,
      totalHarga: json['totalHarga'] as int,
      namaUser: json['namaUser'] as String,
      tanggal: DateTime.parse(json['tanggal']),
      statusOrder: json['statusOrder'] as String?,
      noHp: json['nomorHpAktif'] as String?,
      paymentChannel: json['paymentChannel'] as String?,
      items: parsedItems,
    );
  }
}

class TransactionItem {
  final String namaProduk;
  final String kategori;
  final int hargaProduk;
  final int qtyProduk;
  final String? fotoProduk;
  final int subtotal;

  TransactionItem({
    required this.namaProduk,
    required this.kategori,
    required this.hargaProduk,
    required this.qtyProduk,
    this.fotoProduk,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      namaProduk: json['namaProduk'] as String,
      kategori: json['kategori'] as String,
      hargaProduk: json['hargaProduk'] as int,
      qtyProduk: json['qtyProduk'] as int,
      fotoProduk: json['fotoProduk'] as String?,
      subtotal: json['subtotal'] as int,
    );
  }
}
