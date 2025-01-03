import 'dart:async';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/transaction.dart';
import 'package:point_of_salles_mobile_app/services/payment_service.dart';
import 'package:point_of_salles_mobile_app/services/transaction_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final String? invoiceId;
  const PaymentScreen({super.key, this.invoiceId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TransactionService _transaksiService = TransactionService();
  final PaymentService _paymentService = PaymentService();
  Transaction? _transaksi;
  bool _isLoading = false;
  String? _error;
  Timer? _countdownTimer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    debugPrint("invoice id: ${widget.invoiceId}");
    _loadPendingTransactionByInvoice(widget.invoiceId!);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (_transaksi?.vaPaymentStatus?.expirationDate == null) return;

    final expirationDate =
        DateTime.parse(_transaksi!.vaPaymentStatus!.expirationDate);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = expirationDate.difference(now);

      if (difference.isNegative) {
        setState(() {
          _countdownText = 'Waktu pembayaran telah habis';
        });
        timer.cancel();
      } else {
        final hours = difference.inHours;
        final minutes = difference.inMinutes.remainder(60);
        final seconds = difference.inSeconds.remainder(60);

        setState(() {
          _countdownText =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  Future<void> _loadPendingTransaction() async {
    try {
      setState(() => _isLoading = true);

      final response = await _transaksiService.getPendingTransaction();

      if (!mounted) return;

      debugPrint("response get pending: ${response.data}");
      debugPrint("response get pending status: ${response.status}");
      debugPrint("response get pending is null: ${response.data == null}");
      if (response.status && response.data != null) {
        setState(() {
          _transaksi = response.data;
          _error = null;
          if (_transaksi?.vaPaymentStatus != null) {
            _startCountdown();
          }
        });
      } else {
        debugPrint(
            "error response get pending transaction: ${response.message}");
        setState(() {
          _error = response.message ?? 'Data tidak ditemukan';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat data';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPendingTransactionByInvoice(String invoiceId) async {
    try {
      setState(() => _isLoading = true);

      final response =
          await _transaksiService.getPendingTransactionByInvoice(invoiceId);

      if (!mounted) return;

      if (response.status && response.data != null) {
        setState(() {
          _transaksi = response.data;
          if (_transaksi?.vaPaymentStatus != null) {
            _startCountdown();
          }
          _error = null;
        });
      } else {
        setState(() {
          _error = response.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("error get pending transaction by invoice: $e");
      setState(() {
        _error = 'Terjadi kesalahan saat memuat data';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String formatRupiah(int nominal) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(nominal);
  }

  void _copyToClipboard(String text, {String? message}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Teks berhasil disalin'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPaymentStatusInfo() {
    if (_transaksi?.vaPaymentStatus != null) {
      return Column(
        children: [
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Virtual Account',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nomor VA'),
                    GestureDetector(
                      onTap: () => _copyToClipboard(
                          _transaksi!.vaPaymentStatus!.accountNumber),
                      child: Row(
                        children: [
                          Text(_transaksi!.vaPaymentStatus!.accountNumber),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bank'),
                    Text(_transaksi!.vaPaymentStatus!.bankCode.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status'),
                    Text(_transaksi!.vaPaymentStatus!.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_transaksi?.ewalletPaymentStatus != null) {
      return Column(
        children: [
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi E-Wallet',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Channel'),
                    Text(_transaksi!.ewalletPaymentStatus!.channelCode
                        .toUpperCase()),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status'),
                    Text(_transaksi!.ewalletPaymentStatus!.status),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Referensi'),
                    Text(_transaksi!.ewalletPaymentStatus!.referenceId),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Menunggu Pembayaran',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Menunggu Pembayaran',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Selesaikan Pembayaran dengan',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _transaksi?.paymentChannel ?? '',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_transaksi?.vaPaymentStatus != null) ...[
                    const SizedBox(height: 24.0),
                    Center(
                      child: Text(
                        _countdownText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24.0),
                  const SizedBox(height: 24.0),
                  if (_transaksi?.ewalletPaymentStatus?.actions
                              .qrCheckoutString !=
                          null ||
                      _transaksi?.ewalletPaymentStatus?.actions
                              .mobileDeeplinkCheckoutUrl !=
                          null ||
                      _transaksi?.ewalletPaymentStatus?.actions
                              .mobileWebCheckoutUrl !=
                          null) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'QR Code Pembayaran',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: QrImageView(
                        data: _transaksi!.ewalletPaymentStatus!.actions
                                .qrCheckoutString ??
                            _transaksi!.ewalletPaymentStatus!.actions
                                .mobileDeeplinkCheckoutUrl ??
                            _transaksi!.ewalletPaymentStatus!.actions
                                .mobileWebCheckoutUrl ??
                            '',
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Ringkasan Pembelian',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Invoice'),
                            GestureDetector(
                              onTap: () => _copyToClipboard(
                                  _transaksi?.invoiceId ?? '',
                                  message: 'Nomor Invoice berhasil disalin'),
                              child: Row(
                                children: [
                                  Text(_transaksi?.invoiceId ?? ''),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.copy, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nama'),
                            Text(_transaksi?.namaUser ?? ''),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        ..._transaksi?.transaksiDetail
                                .map((detail) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(detail.namaProduk),
                                          Text(
                                              '${detail.qtyProduk}x ${formatRupiah(detail.hargaProduk)}'),
                                        ],
                                      ),
                                    ))
                                .toList() ??
                            [],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              formatRupiah(_transaksi?.totalHarga ?? 0),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildPaymentStatusInfo(),
                  const SizedBox(height: 24.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_transaksi!.vaPaymentStatus != null) {
                          await _checkPaymentStatus(
                              _transaksi!.vaPaymentStatus!.id);
                        } else if (_transaksi!.ewalletPaymentStatus != null) {
                          await _checkPaymentStatus(
                              _transaksi!.ewalletPaymentStatus!.id);
                        }
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
                      child: const Text('Cek Status Pembayaran'),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_transaksi?.vaPaymentStatus != null) {
                          // Untuk pembayaran VA
                          Navigator.pushNamed(context, '/payment_simulator');
                        } else if (_transaksi?.ewalletPaymentStatus != null) {
                          // Untuk pembayaran E-wallet
                          final paymentUrl = _transaksi?.ewalletPaymentStatus
                                  ?.actions.qrCheckoutString ??
                              _transaksi?.ewalletPaymentStatus?.actions
                                  .mobileDeeplinkCheckoutUrl ??
                              _transaksi?.ewalletPaymentStatus?.actions
                                  .mobileWebCheckoutUrl;

                          if (paymentUrl != null) {
                            Navigator.pushNamed(context, '/webview',
                                arguments: {'url': paymentUrl});
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColor.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: MediaQuery.of(context).size.width * 0.215,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('Simulator Pembayaran'),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            const Color.fromARGB(255, 108, 150, 255),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: MediaQuery.of(context).size.width * 0.35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
    );
  }

  Future<void> _checkPaymentStatus(String idTransaction) async {
    setState(() {
      _isLoading = true;
    });
    try {
      BaseResponse checkPayment = await _paymentService.checkPaymentStatus(
        idTransaction: idTransaction,
      );

      if (checkPayment.data != null &&
          (checkPayment.data['status'] == 'SUCCEEDED' ||
              checkPayment.data['status'] == 'INACTIVE')) {
        if (!mounted) return;

        Navigator.of(context).pushReplacementNamed(
          '/payment_success',
          arguments: checkPayment.data,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Belum melakukan pembayaran'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Error checking payment status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
