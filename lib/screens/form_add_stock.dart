import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';

// ignore: must_be_immutable
class FormAddStock extends StatefulWidget {
  Product product;
  FormAddStock({super.key, required this.product});

  @override
  // ignore: library_private_types_in_public_api
  _FormAddStockState createState() => _FormAddStockState();
}

class _FormAddStockState extends State<FormAddStock> {
  final TextEditingController _stokController = TextEditingController();
  final ProductService _stockService = ProductService();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    // Validasi input stok
    if (_stokController.text.isEmpty) {
      setState(() {
        _errorMessage = "Jumlah stok harus diisi";
      });
      return;
    }

    final int? qty = int.tryParse(_stokController.text);
    if (qty == null || qty <= 0) {
      setState(() {
        _errorMessage = "Jumlah stok harus berupa angka positif";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Panggil service untuk menambah stok
    final response = await _stockService.addProductStock(
      productId: widget.product.id,
      qty: qty,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.status) {
      // Berhasil menambah stok
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Stok berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } else {
      // Gagal menambah stok
      setState(() {
        _errorMessage = response.message ?? 'Gagal menambah stok produk';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Tambah Stok Produk',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          )),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primary))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    TextField(
                      controller: _stokController,
                      decoration: InputDecoration(
                        hintText: 'Tambah Stok Produk',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) // Tampilkan pesan kesalahan
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
