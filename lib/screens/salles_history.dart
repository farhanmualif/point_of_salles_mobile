import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/transaction.dart';
import 'package:point_of_salles_mobile_app/screens/payment_screen.dart';
import 'package:point_of_salles_mobile_app/screens/payment_success.dart';
import 'package:point_of_salles_mobile_app/services/transaction_service.dart';
import 'package:intl/intl.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class SallesHistory extends StatefulWidget {
  const SallesHistory({super.key});

  @override
  State<SallesHistory> createState() => _SallesHistoryState();
}

class _SallesHistoryState extends State<SallesHistory> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionHistory> _transactions = [];
  bool _isLoading = true;
  String _error = '';
  bool _mounted = true;

  // Constants
  static const double _cardPadding = 16.0;
  static const double _borderRadius = 12.0;
  static const double _imageSize = 70.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (!_mounted) return;

    try {
      setState(() => _isLoading = true);
      final response = await _transactionService.getTransactionHistory();
      if (!_mounted) return;

      if (response.status) {
        setState(() {
          _transactions = response.data ?? [];
          _isLoading = false;
          _error = '';
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_mounted) return;

      setState(() {
        _error = 'Terjadi kesalahan saat memuat data';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;
    await _loadTransactions();
  }

  Widget _buildStatusBadge(String? status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;

    switch (status?.toUpperCase() ?? 'PENDING') {
      case 'PAID':
        backgroundColor = AppColor.primary;
        displayText = 'Dibayar';
        break;
      case 'PENDING':
        backgroundColor = Colors.orange;
        displayText = 'Menunggu';
        break;
      case 'EXPIRED':
        backgroundColor = Colors.red;
        displayText = 'Kadaluarsa';
        break;
      case 'UNPAID':
        backgroundColor = Colors.red[300]!;
        displayText = 'Belum Dibayar';
        break;
      default:
        backgroundColor = Colors.grey;
        displayText = status ?? 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatPaymentMethod(String? method) {
    if (method == null) return 'Tunai';
    if (method.startsWith('EWALLET_')) {
      return method.replaceAll('EWALLET_', '');
    } else if (method == 'QRIS') {
      return 'QRIS';
    } else if (method == 'CASH') {
      return 'Tunai';
    } else {
      return 'VA $method';
    }
  }

  void _handleTransactionTap(TransactionHistory transaction) {
    switch (transaction.statusOrder?.toUpperCase()) {
      case 'PAID':
        final paymentData = {
          'invoiceId': transaction.invoiceId,
          'tanggalBayar': transaction.tanggal.toIso8601String(),
          'totalHarga': transaction.totalHarga,
          'namaMitra': transaction.namaUser,
          'nomorHpAktif': transaction.noHp ?? 'Unknown',
          'statusOrder': transaction.statusOrder,
        };

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(data: paymentData),
          ),
        );
        break;
      case 'PENDING':
      case 'UNPAID':
      case null:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PaymentScreen(invoiceId: transaction.invoiceId),
          ),
        );
        break;
    }
  }

  // Shimmer loading widget
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 5,
        itemBuilder: (_, __) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 20,
                color: Colors.white,
              ),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 200,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 16,
                color: Colors.white,
              ),
              Container(
                width: 100,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Optimized transaction card
  Widget _buildTransactionCard(TransactionHistory transaction) {
    // Debug print untuk memeriksa data

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(_cardPadding),
          title: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleTransactionTap(transaction),
            child: _buildTransactionHeader(transaction),
          ),
          subtitle: _buildTransactionSubtitle(transaction, currencyFormatter),
          children: [
            if (transaction.items.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Detail Item:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ...transaction.items
                        .map((item) => _buildItemCard(item))
                        .toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(TransactionHistory transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Invoice: ${transaction.invoiceId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _buildStatusBadge(transaction.statusOrder ?? 'PENDING'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Customer: ${transaction.namaUser}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTransactionSubtitle(
    TransactionHistory transaction,
    NumberFormat currencyFormatter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currencyFormatter.format(transaction.totalHarga),
              style: const TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              _formatPaymentMethod(transaction.paymentChannel),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(transaction.tanggal),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: const Color(0xfff6f6f6),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Riwayat Penjualan',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_transactions.isEmpty) {
      return _buildEmptyState();
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _transactions.length,
        itemBuilder: (context, index) =>
            _buildTransactionCard(_transactions[index]),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada transaksi',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(TransactionItem item) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Container(
              width: _imageSize,
              height: _imageSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.primary.withOpacity(0.2),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: item.fotoProduk?.isNotEmpty == true
                  ? Image.network(
                      item.fotoProduk!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kategori: ${item.kategori}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Kuantitas: ${item.qtyProduk}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currencyFormatter.format(item.hargaProduk)} x ${item.qtyProduk}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      currencyFormatter.format(item.subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
