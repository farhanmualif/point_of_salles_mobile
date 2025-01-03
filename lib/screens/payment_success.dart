import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:point_of_salles_mobile_app/utils/currency_formatter.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:point_of_salles_mobile_app/services/transaction_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const PaymentSuccessScreen({super.key, required this.data});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  final TransactionService _transactionService = TransactionService();
  bool _isInit = false;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connecting = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    debugPrint("Payment Success Screen Data: ${widget.data}");
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    try {
      if (!context.mounted) return;
      setState(() {
        _isInit = true;
      });
    } catch (e) {
      debugPrint('Printer init error: ${e.toString()}');
    }
  }

  Future<void> _showPrinterSelection(BuildContext context) async {
    bool permissionsGranted = await _requestBluetoothPermissions();
    if (!permissionsGranted) return;

    // Check if bluetooth is on
    bool? isOn = await printer.isOn;
    if (isOn != true) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon aktifkan Bluetooth')),
      );
      return;
    }

    // Get available devices
    _devices = await printer.getBondedDevices();

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pilih Printer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_devices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Tidak ada printer yang terhubung.\nSilakan hubungkan printer di pengaturan Bluetooth',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<BluetoothDevice>(
                    value: _selectedDevice,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Pilih printer'),
                    items: _devices.map((device) {
                      return DropdownMenuItem(
                        value: device,
                        child: Text(device.name ?? 'Unknown Device'),
                      );
                    }).toList(),
                    onChanged: (device) {
                      setState(() => _selectedDevice = device);
                    },
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedDevice == null || _connecting
                    ? null
                    : () async {
                        setState(() => _connecting = true);
                        try {
                          await printer.connect(_selectedDevice!);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          await printReceipt(context);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                            ),
                          );
                        } finally {
                          setState(() => _connecting = false);
                        }
                      },
                child: _connecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Hubungkan & Cetak'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestBluetoothPermissions() async {
    // For Android 12 and above
    if (await Permission.bluetoothConnect.status.isDenied ||
        await Permission.bluetoothScan.status.isDenied) {
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
    }

    // For Android 11 and below
    if (await Permission.bluetooth.status.isDenied ||
        await Permission.location.status.isDenied) {
      await Permission.bluetooth.request();
      await Permission.location.request();
    }

    // Check final status
    bool bluetoothGranted = await Permission.bluetoothConnect.isGranted ||
        await Permission.bluetooth.isGranted;
    bool scanGranted = await Permission.bluetoothScan.isGranted ||
        await Permission.location.isGranted;

    if (!bluetoothGranted || !scanGranted) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin Bluetooth diperlukan untuk mencetak struk'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> printReceipt(BuildContext context) async {
    try {
      if (!(await printer.isConnected ?? false)) {
        if (!context.mounted) return;
        _showPrinterSelection(context);
        return;
      }

      if (!mounted) return;
      setState(() => _loading = true);

      // Get receipt data from API
      final transactionId =
          widget.data['external_id'] ?? widget.data['invoiceId'];
      debugPrint("Fetching receipt data for ID: $transactionId");
      if (transactionId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID Transaksi tidak ditemukan')),
        );
        setState(() => _loading = false);
        return;
      }

      final response =
          await _transactionService.getReceiptData(transactionId.toString());
      debugPrint("Receipt API Response status: ${response.status}");

      if (!mounted) return;

      if (!response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        setState(() => _loading = false);
        return;
      }

      final receiptData = response.data!;

      // Print receipt header
      await printer.printCustom("Point of Sales", 2, 1);
      await printer.printCustom("--------------------------------", 1, 1);

      // Print transaction info
      await printer.printCustom(
          "No. Invoice: ${receiptData['invoice_id'] ?? '-'}", 1, 0);
      await printer.printCustom(
          "Tanggal: ${receiptData['transaction_date'] ?? '-'}", 1, 0);
      await printer.printCustom(
          "Kasir: ${receiptData['customer_name'] ?? '-'}", 1, 0);
      await printer.printCustom("--------------------------------", 1, 1);

      // Print items
      final items = receiptData['items'] as List<dynamic>;
      for (var item in items) {
        final productName = item['product_name']?.toString() ?? '-';
        final quantity = item['quantity']?.toString() ?? '0';
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final subtotal = (item['subtotal'] as num?)?.toDouble() ?? 0.0;

        await printer.printCustom(productName, 1, 0);
        await printer.printCustom(
            "$quantity x ${CurrencyFormatter.formatRupiah(price)}", 1, 0);
        await printer.printCustom(
            CurrencyFormatter.formatRupiah(subtotal), 1, 2);
      }

      await printer.printCustom("--------------------------------", 1, 1);

      // Print total
      final totalAmount =
          (receiptData['total_amount'] as num?)?.toDouble() ?? 0.0;
      await printer.printCustom("TOTAL:", 1, 0);
      await printer.printCustom(
          CurrencyFormatter.formatRupiah(totalAmount), 2, 2);

      // Print payment info
      await printer.printCustom("--------------------------------", 1, 1);
      await printer.printCustom(
          "Metode Pembayaran: ${receiptData['payment_method'] ?? 'CASH'}",
          1,
          0);
      await printer.printCustom(
          "Status: ${receiptData['payment_status'] ?? '-'}", 1, 0);

      // Print footer
      await printer.printCustom("--------------------------------", 1, 1);
      await printer.printCustom("Terima Kasih", 1, 1);
      await printer.printCustom("Silakan datang kembali", 1, 1);
      await printer.printNewLine();

      // Cut paper
      await printer.paperCut();

      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Struk berhasil dicetak')),
      );
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencetak struk: ${e.toString()}')),
      );
    }
  }

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
                  'Berhasil melakukan pembayaran ${_getAmount(widget.data)} dari \n${widget.data['name'] ?? widget.data['namaMitra'] ?? 'Unknown'}',
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
                        widget.data['external_id'] ??
                            widget.data['invoiceId'] ??
                            '',
                        copyable: true,
                      ),
                      _buildDetailRow(
                        'Tanggal',
                        _formatDate(widget.data['tanggalBayar'] ??
                            widget.data['expiration_date'] ??
                            widget.data['created']),
                      ),
                      _buildDetailRow(
                          'Nominal',
                          CurrencyFormatter.formatRupiah(
                              double.parse(_getAmount(widget.data)))),
                      _buildDetailRow(
                        'No. Handphone',
                        widget.data['account_number'] ??
                            widget.data['nomorHpAktif'] ??
                            '-',
                      ),
                      _buildDetailRow(
                        'Status',
                        widget.data['status'] ??
                            widget.data['statusOrder'] ??
                            'Unknown',
                        isSuccess: (widget.data['status'] == 'INACTIVE' ||
                            widget.data['statusOrder'] == 'PAID'),
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
                            double.parse(_getAmount(widget.data))),
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
                // Print Receipt Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      printReceipt(context);
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.print, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cetak Struk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
