import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> data; // Menyimpan data yang diterima

  const PaymentSuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Success Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Colors.green.shade400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Success Text
            const Center(
              child: Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Center(
              child: Text(
                'Successfully topped up ${data['expected_amount']} to ${data['name']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Transaction Details
            Text(
              'Detail Transaction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            // Transaction Details List
            _buildDetailRow('Transaction ID', data['external_id']),
            _buildDetailRow(
                'Date',
                DateTime.parse(data['expiration_date'])
                    .toLocal()
                    .toString()), // Mengubah format tanggal
            _buildDetailRow('Nominal', 'IDR ${data['expected_amount']}'),
            _buildDetailRow(
                'Admin', 'IDR 0'), // Jika ada biaya admin, sesuaikan di sini
            _buildDetailRow("Recipient's number", data['account_number']),
            _buildDetailRow('Status', data['status'],
                isSuccess: data['status'] == 'INACTIVE'), // Menyesuaikan status
            const SizedBox(height: 30),
            // Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'IDR 10000', // Sesuaikan dengan total yang diharapkan
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/main_screen');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColor.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: MediaQuery.of(context).size.width * 0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text('Kembali Ke Beranda'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          isSuccess
              ? Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      value == 'INACTIVE' ? "success" : "failed",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Text(
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
}
