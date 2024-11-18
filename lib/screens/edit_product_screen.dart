import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  // ignore: library_private_types_in_public_api
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final ProductService _productService = ProductService();

  String? selectedCategory;
  XFile? image;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set nilai awal dari product yang ingin diupdate
    _namaProdukController.text = widget.product.namaProduk;
    _hargaController.text = "${widget.product.hargaProduk}";
    selectedCategory = widget.product.kategori == "Makanan" ? 'food' : 'drink';
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    // Meminta izin akses penyimpanan
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          setState(() {
            image = pickedFile;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin akses penyimpanan ditolak')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      String kategori = selectedCategory == 'food' ? 'Makanan' : 'Minuman';
      int harga = int.parse(_hargaController.text);
      File? imageFile = image != null ? File(image!.path) : null;

      // Panggil fungsi updateProduct
      final response = await _productService.updateProduct(
        productId: widget.product.id,
        namaProduk: _namaProdukController.text,
        kategori: kategori,
        harga: harga,
        foto: imageFile,
      );

      setState(() {
        isLoading = false;
      });

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui')),
        );
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal memperbarui produk'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
          'Edit Produk',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Produk*', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _namaProdukController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nama produk harus diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Harga*', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga harus diisi';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Kategori*', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: selectedCategory,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Kategori harus dipilih'
                      : null,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'food', child: Text('Makanan')),
                    DropdownMenuItem(value: 'drink', child: Text('Minuman')),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Foto Produk', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: image == null
                        ? const Icon(Icons.add_a_photo,
                            size: 50, color: Colors.grey)
                        : Image.file(File(image!.path), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _handleSubmit();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
