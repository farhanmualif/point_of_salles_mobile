import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/transaction.dart';
import 'package:point_of_salles_mobile_app/services/transaction_service.dart';

class SallesHistory extends StatefulWidget {
  const SallesHistory({super.key});

  @override
  State<SallesHistory> createState() => _SallesHistoryState();
}

class _SallesHistoryState extends State<SallesHistory> {
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = true;
  String _error = '';
  List<TransactionHistory> _transactions = [];
  bool _mounted = true;

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

    setState(() => _isLoading = true);
    await _loadTransactions();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penjualan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Center(
        child: Text('Belum ada transaksi'),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        itemCount: _transactions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionHistory transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0, // Remove shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!, width: 1), // Add thin border
      ),
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: const Color.fromARGB(
              0, 254, 254, 254), // Remove the expansion tile bottom line
        ),
        child: ExpansionTile(
          title: Text(
            'Invoice: ${transaction.invoiceId}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${transaction.namaUser}'),
              Text(
                'Total: Rp ${transaction.totalHarga.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Text('Tanggal: ${_formatDate(transaction.tanggal)}'),
            ],
          ),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transaction.items.length,
              itemBuilder: (context, index) {
                final item = transaction.items[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.fotoProduk?.isNotEmpty == true
                            ? Image.network(
                                item.fotoProduk!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child:
                                        const Icon(Icons.image_not_supported),
                                  );
                                },
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
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
                            Text('Kategori: ${item.kategori}'),
                            Text('Kuantitas: ${item.qtyProduk}'),
                            Text(
                              'Harga: Rp ${item.hargaProduk.toStringAsFixed(0)}',
                            ),
                            Text(
                              'Subtotal: Rp ${item.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
