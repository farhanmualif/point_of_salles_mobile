import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:point_of_salles_mobile_app/models/transaction.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/services/transaction_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TransactionService _transactionService = TransactionService();
  int countProduct = 0;
  int totalStockProduct = 0;
  int? _totalTransaction = 0;
  bool _isLoading = true;
  final bool _mounted = true;

  @override
  void initState() {
    super.initState();
    getProduct();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!_mounted) return;

    try {
      setState(() => _isLoading = true);
      final response = await _transactionService.getTransactionHistory();

      if (!_mounted) return;

      if (response.status) {
        setState(() {
          // _transactions = response.data ?? [];
          _totalTransaction = response.data?.length;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getProduct() async {
    try {
      final value = await ProductService().fetchProducts();
      if (value.data != null) {
        setState(() {
          countProduct += value.data!.length;
          for (var product in value.data!) {
            totalStockProduct += product.stok; // Accumulate stock
          }
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[200]),
            child: SvgPicture.asset(
              "assets/icons/user.svg",
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200, // Fixed height
              child: Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(
                      icon: Icons.work,
                      iconColor: Colors.blue,
                      title: 'Produk',
                      value: countProduct.toString(), // Display countProduct
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildDashboardCard(
                      icon: Icons.shopping_cart,
                      iconColor: Colors.green,
                      title: 'Anda Sudah Melayani',
                      value: '$_totalTransaction Transaksi',
                      valueColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.9,
              child: _buildDashboardCard(
                icon: Icons.attach_money_sharp,
                iconColor: Colors.orange,
                title: 'Total Stok Produk',
                value: totalStockProduct.toString(), // Display countProduct
                valueColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(width: 0.1, color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor ?? iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
