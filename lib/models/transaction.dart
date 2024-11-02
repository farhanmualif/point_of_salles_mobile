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
          ? VAPaymentStatus.fromJson(json['payment_status'])
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
