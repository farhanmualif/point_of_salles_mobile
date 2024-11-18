import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  bool inventoryPriceEnabled = false;
  String? selectedCategory;
  XFile? image;
  bool isLoading = false;

  // Controllers untuk form fields
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final ProductService _productService = ProductService();

  @override
  void dispose() {
    _namaProdukController.dispose();
    _hargaController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    // Meminta izin
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Izin diberikan, lanjutkan untuk memilih gambar
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
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
          );
        }
      } catch (e) {
        print('Error picking image: $e');
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    } else {
      // Izin ditolak
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin akses penyimpanan ditolak')),
      );
    }
  }

  void _handlSubmit() async {
    setState(() {
      isLoading = true;
    });

    try {
      String kategori = selectedCategory == 'food' ? 'Makanan' : 'Minuman';
      int harga = int.parse(_hargaController.text);
      File? imageFile = image != null ? File(image!.path) : null;

      final response = await _productService.createProduct(
          namaProduk: _namaProdukController.text,
          kategori: kategori,
          harga: harga,
          foto: imageFile,
          qty: int.parse(_qtyController.text));

      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response.message ?? 'Gagal menambahkan produk'),
              backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent),
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
          'Tambah Produk',
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
                // Product Image Section
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: image == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(image!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                const Text('Nama Produk*', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                TextFormField(
                  // Gunakan TextFormField sebagai pengganti TextField
                  controller: _namaProdukController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Harga*', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                TextFormField(
                  // Gunakan TextFormField
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
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

                // Tambahkan Form Field untuk Kuantitas
                const Text('Kuantitas*', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kuantitas harus diisi';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Kuantitas harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Kategori*', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  // Sudah menggunakan FormField
                  decoration: InputDecoration(
                    helperText: "Pilih Kategori",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  value: selectedCategory,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kategori harus dipilih';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'food',
                      child: Text('Makanan'),
                    ),
                    DropdownMenuItem(
                      value: 'drink',
                      child: Text('Minuman'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _handlSubmit();
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
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: Colors.white,
                          ))
                        : const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
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
}
