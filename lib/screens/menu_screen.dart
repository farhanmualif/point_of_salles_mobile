import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:point_of_salles_mobile_app/screens/products_screen.dart';
import 'package:point_of_salles_mobile_app/screens/stock_produk_screen.dart';
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'Ringkasan Bisnis',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            _buildTopCards(),
                            const SizedBox(height: 16),
                            _buildBottomCard(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5, 
      centerTitle: true,
      title: const Text(
        'Dashboard',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildTopCards() {
    return Row(
      children: [
        Expanded(
          child: _buildDashboardCard(
            onTap: null,
            icon: Icons.inventory_2_rounded,
            iconColor: Colors.blue,
            title: 'Total Produk',
            value: countProduct.toString(),
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDashboardCard(
            onTap: null,
            icon: Icons.point_of_sale_rounded,
            iconColor: Colors.green,
            title: 'Total Transaksi',
            value: '$_totalTransaction',
            subtitle: 'Transaksi',
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCard() {
    return _buildDashboardCard(
      onTap: null,
      icon: Icons.inventory_rounded,
      iconColor: Colors.orange,
      title: 'Total Stok Produk',
      value: totalStockProduct.toString(),
      isLarge: true,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtitle,
    bool isLarge = false,
    VoidCallback? onTap,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 150 : 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isLarge ? 32 : 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLarge ? 28 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
