import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:point_of_salles_mobile_app/services/payment_service.dart';

class PaymentSimulatorScreen extends StatefulWidget {
  const PaymentSimulatorScreen({super.key});

  @override
  State<PaymentSimulatorScreen> createState() => _PaymentSimulatorScreenState();
}

class _PaymentSimulatorScreenState extends State<PaymentSimulatorScreen> {
  final TextEditingController _externalIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  Map<String, dynamic>? _paymentData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  Future<void> _handleEwalletPayment() async {
    final String? paymentUrl = _paymentData?['qrCheckoutString'] ??
        _paymentData?['mobileDeeplinkCheckoutUrl'] ??
        _paymentData?['mobileWebCheckoutUrl'];

    if (paymentUrl != null) {
      Navigator.pushNamed(context, '/webview', arguments: {'url': paymentUrl});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL pembayaran tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _simulateVAPayment() async {
    if (_externalIdController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final simulateResponse = await _paymentService.simulateVAPayment(
        externalId: _externalIdController.text,
        amount: _amountController.text,
      );

      if (!mounted) return;

      if (simulateResponse.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil disimulasikan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (simulateResponse.data?['error_code'] == 'INVALID_AMOUNT_ERROR') {
          final expectedAmount =
              simulateResponse.data?['message'].toString().split('is ').last;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Jumlah pembayaran harus $expectedAmount'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _amountController.text = expectedAmount ?? '10000';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(simulateResponse.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEwallet = _paymentData?['payment_method'] == 'EWALLET';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEwallet ? 'E-Wallet Payment' : 'VA Payment Simulator'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isEwallet ? _buildEwalletPayment() : _buildVAPayment(),
            ),
    );
  }

  Widget _buildEwalletPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Klik tombol di bawah untuk melanjutkan pembayaran',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _handleEwalletPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Lanjutkan ke Pembayaran'),
        ),
      ],
    );
  }

  Widget _buildVAPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _externalIdController,
          decoration: InputDecoration(
            labelText: 'ID Transaksi',
            hintText: 'Masukkan ID Transaksi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Jumlah Pembayaran',
            hintText: 'Masukkan jumlah pembayaran',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixText: 'Rp ',
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _simulateVAPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Simulasi Pembayaran'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _externalIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
