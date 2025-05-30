import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/screens/add_product_form.dart';
import 'package:point_of_salles_mobile_app/screens/produk_detail_screen.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isLoading = false;
  String? _aksesName;
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
        _aksesName = userData['aksesName'];
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
                'List Produk',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              actions: [
                _akses == '1' || _akses == '2'
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const AddProductForm()));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.grey[200],
                          ),
                          child: const Icon(Icons.add),
                        ),
                      )
                    : const Text(""),
              ],
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
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            buildProductImage(imageUrl),
            const SizedBox(width: 16),
            Expanded(child: buildProductInfo(item)),
            _akses == '1' || _akses == '2'
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productId: item.id),
                      ));
                    },
                  )
                : const Text(""),
          ],
        ),
      ),
    );
  }

  Widget buildProductImage(String imageUrl) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {},
    );
  }

  Widget buildProductInfo(Product item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.namaProduk,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Rp ${item.hargaProduk.toStringAsFixed(0)}',
            style: const TextStyle(
                color: AppColor.primary, fontWeight: FontWeight.bold)),
       
      ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchbarController,
        decoration: InputDecoration(
          hintText: 'Search menu...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        onChanged: searchMenu,
      ),
    );
  }
}
