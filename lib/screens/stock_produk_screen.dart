import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/screens/form_add_stock.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockProductScreen extends StatefulWidget {
  const StockProductScreen({super.key});

  @override
  State<StockProductScreen> createState() => _StockProductScreenState();
}

class _StockProductScreenState extends State<StockProductScreen> {
  bool isLoading = false;
  String? _akses;

  List<Product> filteredMenuItems = [];
  List<Product> allMenuItems = [];

  final ProductService productService = ProductService();
  TextEditingController searchbarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts(); // Fetch products on initialization
    _initializeData();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final response = await productService.fetchProducts();

    if (response.status) {
      setState(() {
        allMenuItems = response.data ?? []; // Store fetched products
        filteredMenuItems = allMenuItems; // Initialize filtered items
      });
    } else {
      showMessage(response.message, isError: true); // Show error message
    }

    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }

  void _toggleProductStatus(String productId) async {
    debugPrint("cek product id $productId");

    try {
      final response = await productService.updateProductStockStatus(
        productId: productId,
      );

      if (response.status) {
        showMessage(response.message);
        // Update status produk secara lokal tanpa reload seluruh halaman
        setState(() {
          allMenuItems = allMenuItems.map((product) {
            if (product.id == productId) {
              return Product(
                id: product.id,
                namaProduk: product.namaProduk,
                hargaProduk: product.hargaProduk,
                stok: product.stok,
                fotoProduk: product.fotoProduk,
                statusStok: product.statusStok == "1" ? "0" : "1", kategori: '',
                slugProduk: '', status: '', mitraId: '',
                // tambahkan properti lain yang diperlukan
              );
            }
            return product;
          }).toList();

          // Update filtered items juga
          filteredMenuItems = [...allMenuItems];
        });
      } else {
        showMessage(response.message, isError: true);
      }
    } catch (e) {
      showMessage('Terjadi kesalahan: ${e.toString()}', isError: true);
    }
  }

  Future<void> _initializeData() async {
    try {
      await _fetchUserData(); // Ambil data user setelah produk
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userDataJson = await SecureStorageService.getUserData();
      if (userDataJson != null) {
        final userData = json.decode(userDataJson);
        _akses = userData['akses'];
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppColor.primary)),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFF9F9F9),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'List Stock Produk',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            body: Container(
              color: const Color(0xfff6f6f6),
              child: buildMenu(),
            ),
          );
  }

  Widget buildMenu() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: buildContent()),
      ],
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (filteredMenuItems.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ListView.builder(
      itemCount: filteredMenuItems.length,
      itemBuilder: (context, index) => buildMenuItem(filteredMenuItems[index]),
    );
  }

  Widget buildMenuItem(Product item) {
    final imageUrl = item.fotoProduk != null
        ? '${dotenv.env['API_URL']}/produk_thumbnail/${item.fotoProduk}'
        : '${dotenv.env['API_URL']}/produk_thumbnail/thumbnail_1.jpg';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            buildProductImage(imageUrl),
            const SizedBox(width: 16),
            Expanded(child: buildProductInfo(item)),
            if (_akses == '1' || _akses == '2')
              Row(
                children: [
                  _buildStatusSwitch(item),
                  const SizedBox(width: 8),
                  _buildAddStockButton(item),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildProductImage(String imageUrl) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.primary.withOpacity(0.2), width: 2),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildProductInfo(Product item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.namaProduk,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Rp ${item.hargaProduk.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Stok: ${item.stok}',
            style: TextStyle(
              color: AppColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSwitch(Product item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: item.statusStok == "1",
            onChanged: isLoading
                ? null
                : (bool value) => _toggleProductStatus(item.id),
            activeColor: AppColor.primary,
          ),
        ),
        Text(
          item.statusStok == "1" ? "Aktif" : "Tidak Aktif",
          style: TextStyle(
            fontSize: 11,
            color: item.statusStok == "1" ? AppColor.primary : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddStockButton(Product item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: AppColor.primary, size: 20),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => FormAddStock(product: item)),
            );
          },
        ),
        const Text(
          "Tambah Stok",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchbarController,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: AppColor.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: searchMenu,
      ),
    );
  }

  void searchMenu(String query) {
    setState(() {
      filteredMenuItems = query.isEmpty
          ? allMenuItems
          : allMenuItems
              .where((item) =>
                  item.namaProduk.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }
}
