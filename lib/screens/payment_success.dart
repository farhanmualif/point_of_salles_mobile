import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:point_of_salles_mobile_app/utils/currency_formatter.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const PaymentSuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Success Icon dengan animasi
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade400,
                  ),
                ),
                const SizedBox(height: 32),
                // Success Text
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  'Berhasil melakukan pembayaran ${_getAmount(data)} dari \n${data['name'] ?? data['namaMitra'] ?? 'Unknown'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Transaction Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow(
                        'ID Transaksi',
                        data['external_id'] ?? data['invoiceId'] ?? '',
                        copyable: true,
                      ),
                      _buildDetailRow(
                        'Tanggal',
                        _formatDate(data['tanggalBayar'] ??
                            data['expiration_date'] ??
                            data['created']),
                      ),
                      _buildDetailRow(
                          'Nominal',
                          CurrencyFormatter.formatRupiah(
                              double.parse(_getAmount(data)))),
                      _buildDetailRow(
                        'No. Handphone',
                        data['account_number'] ?? data['nomorHpAktif'] ?? '-',
                      ),
                      _buildDetailRow(
                        'Status',
                        data['status'] ?? data['statusOrder'] ?? 'Unknown',
                        isSuccess: (data['status'] == 'INACTIVE' ||
                            data['statusOrder'] == 'PAID'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Total Amount Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(
                            double.parse(_getAmount(data))),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/main_screen', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Kembali Ke Beranda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      return DateTime.parse(dateString).toLocal().toString();
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildDetailRow(String label, String value,
      {bool isSuccess = false, bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (isSuccess)
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green[400],
                ),
                const SizedBox(width: 4),
                Text(
                  (value == 'INACTIVE' ||
                          value == 'SUCCEEDED' ||
                          value == 'PAID')
                      ? "Berhasil"
                      : "Gagal",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                // Tambahkan feedback copy berhasil
              },
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  String _getAmount(Map<String, dynamic> data) {
    // Untuk E-wallet payment
    if (data['charge_amount'] != null) {
      return data['charge_amount'].toString();
    }

    // Untuk VA payment
    if (data['expected_amount'] != null) {
      return data['expected_amount'].toString();
    }

    // Fallback ke totalHarga
    return (data['totalHarga'] ?? 0).toString();
  }
}
