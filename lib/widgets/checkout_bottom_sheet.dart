import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/screens/payment_result_screen.dart';
import 'package:point_of_salles_mobile_app/screens/payment_screen.dart';
import 'package:point_of_salles_mobile_app/screens/payment_success.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:point_of_salles_mobile_app/services/payment_service.dart';
import 'package:point_of_salles_mobile_app/models/xendit_payment_method.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final double totalPayment;

  const CheckoutBottomSheet({super.key, required this.totalPayment});

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _selectedPaymentMethod = 'CASH';
  String? _customerNameError;
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();

  // State for showing bank and e-wallet options
  bool _showBankOptions = false;
  bool _showEWalletOptions = false;
  String? _selectedBank;
  String? _selectedEWallet;
  String? _paymentType;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                // Tambahkan padding bottom untuk keyboard
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildCustomerNameField(
                        "Nama Pelanggan",
                        _customerNameController,
                        const Icon(Icons.person_outline)),
                    const SizedBox(height: 10),
                    _buildCustomerNameField(
                        "Nomor Telfon",
                        _phoneNumberController,
                        const Icon(Icons.phone_outlined)),
                    const SizedBox(height: 10),
                    _buildPaymentMethodSection(),
                    if (_showBankOptions) _buildBankOptions(),
                    if (_showEWalletOptions) _buildEWalletOptions(),
                    const SizedBox(height: 20),
                    _buildTotalPayment(),
                    const SizedBox(height: 20),
                    _buildPayButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildCustomerNameField(
      String hintText, TextEditingController controller, Icon icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorText: _customerNameError,
        prefixIcon: icon,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama pelanggan wajib diisi';
        }
        if (value.length < 3) {
          return 'Nama pelanggan minimal 3 karakter';
        }
        return null;
      },
      onChanged: (value) {
        if (_customerNameError != null) {
          setState(() {
            _customerNameError = null;
          });
        }
      },
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildPaymentOption(
                  'Cash', 'Bayar menggunakan Tunai', 'CASH', Icons.money),
              Divider(height: 1, color: Colors.grey[200]),
              _buildPaymentOption(
                  'Bank Transfer',
                  'Bayar menggunakan Bank Transfer',
                  'TRANSFER',
                  Icons.account_balance),
              Divider(height: 1, color: Colors.grey[200]),
              _buildPaymentOption('E-Wallet', 'Bayar menggunakan E-Wallet',
                  'EWALLET', Icons.account_balance_wallet),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
      String title, String subtitle, String value, IconData icon) {
    return RadioListTile(
      title: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
      value: value,
      groupValue: _selectedPaymentMethod,
      activeColor: AppColor.primary,
      onChanged: (newValue) {
        setState(() {
          _selectedPaymentMethod = newValue.toString();
          _showBankOptions = _selectedPaymentMethod == 'TRANSFER';
          _showEWalletOptions = _selectedPaymentMethod == 'EWALLET';
          _selectedBank = null; // Reset the selected bank
          _selectedEWallet = null; // Reset the selected e-wallet
        });
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildBankOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Pilih Bank',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              for (var method in PaymentMethods.getAllMethods()
                  .where((element) => element.type == 'VIRTUAL_ACCOUNT'))
                RadioListTile(
                  title: Text(method.name),
                  value: method.id,
                  groupValue: _selectedBank,
                  activeColor: AppColor.primary,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedBank = newValue.toString();
                    });
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEWalletOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Pilih E-Wallet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              for (var method in PaymentMethods.getAllMethods()
                  .where((element) => element.type == 'EWALLET'))
                RadioListTile(
                  title: Text(method.name),
                  value: method.id,
                  groupValue: _selectedEWallet,
                  activeColor: AppColor.primary,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedEWallet = newValue.toString();
                    });
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPayment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            'IDR ${widget.totalPayment}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _handlePayment,
        child: const Text(
          'Bayar sekarang',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? paymentType;
    String? codeBank;

    // Tentukan tipe pembayaran dan kode bank berdasarkan pilihan
    switch (_selectedPaymentMethod) {
      case 'TRANSFER':
        if (_selectedBank == null) {
          _showError('Silakan pilih bank terlebih dahulu');
          return;
        }
        paymentType = 'VA';
        codeBank = _selectedBank;
        debugPrint('Selected VA Bank: $codeBank');
        break;

      case 'EWALLET':
        if (_selectedEWallet == null) {
          _showError('Silakan pilih e-wallet terlebih dahulu');
          return;
        }
        paymentType = 'EWALLET';
        codeBank = _selectedEWallet;
        debugPrint('Selected E-Wallet: $codeBank');
        break;

      case 'CASH':
        paymentType = null;
        codeBank = null;
        debugPrint('Payment Method: CASH');
        break;

      default:
        _showError('Metode pembayaran tidak valid');
        return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Debug log
      debugPrint('Payment Request Details:');
      debugPrint('Customer Name: ${_customerNameController.text}');
      debugPrint('Phone Number: ${_phoneNumberController.text}');
      debugPrint('Payment Method: $_selectedPaymentMethod');
      debugPrint('Payment Type: $paymentType');
      debugPrint('Code Bank: $codeBank');

      final paymentResponse = await _paymentService.createPayment(
        customerName: _customerNameController.text,
        paymentMethod: _selectedPaymentMethod,
        typePembayaran: paymentType,
        codeBank: codeBank,
        phoneNumber: _phoneNumberController.text,
      );

      if (!mounted) return;

      if (!paymentResponse.status) {
        _showError('Gagal melakukan pembayaran: ${paymentResponse.message}');
        return;
      }

      if (paymentResponse.data == null) {
        _showError('Gagal membuat pembayaran: ${paymentResponse.message}');
        return;
      }

      // Handle response based on status
      if (paymentResponse.data!['statusOrder'] == "PAID") {
        Navigator.of(context).pushReplacementNamed('/payment_success',
            arguments: paymentResponse.data);
      } else {
        Navigator.of(context).pushReplacementNamed('/payment_screen');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getSelectedPaymentCode() {
    switch (_selectedPaymentMethod) {
      case 'TRANSFER':
        return _selectedBank ?? '';
      case 'EWALLET':
        return _selectedEWallet ?? '';
      case 'CASH':
        return 'CASH';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
