import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/screens/add_product_form.dart';
import 'package:point_of_salles_mobile_app/screens/produk_detail_screen.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const double _cardPadding = 16.0;
  static const double _borderRadius = 12.0;
  static const double _imageSize = 70.0;

  bool isLoading = false;
  String? _akses;

  List<Product> filteredMenuItems = [];
  List<Product> allMenuItems = [];

  final ProductService productService = ProductService();
  TextEditingController searchbarController = TextEditingController();

  final RefreshController _refreshController = RefreshController();

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

  Future<void> _onRefresh() async {
    try {
      await fetchProducts();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildShimmerSearchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (_, __) => _buildShimmerProductCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  Widget _buildShimmerProductCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: _imageSize,
            height: _imageSize,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: isLoading ? _buildShimmerLoading() : _buildContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      title: const Text(
        'Daftar Produk',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      actions: [
        if (_akses == '1' || _akses == '2') _buildAddButton(),
      ],
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppColor.primary),
        ),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddProductForm()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: filteredMenuItems.isEmpty
              ? const Center(child: Text('No items found'))
              : ListView.builder(
                  itemCount: filteredMenuItems.length,
                  itemBuilder: (context, index) =>
                      _buildProductCard(filteredMenuItems[index]),
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
          prefixIcon: const Icon(Icons.search, color: AppColor.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
        onChanged: searchMenu,
      ),
    );
  }

  Widget _buildProductCard(Product item) {
    final imageUrl = item.fotoProduk != null
        ? '${dotenv.env['API_URL']}/${item.fotoProduk}'
        : '${dotenv.env['API_URL']}/produk_thumbnail/thumbnail_1.jpg';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: item.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_cardPadding),
            child: Row(
              children: [
                _buildProductImage(imageUrl),
                const SizedBox(width: 16),
                Expanded(child: _buildProductInfo(item)),
                if (_akses == '1' || _akses == '2') _buildEditButton(item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      width: _imageSize,
      height: _imageSize,
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

  Widget _buildProductInfo(Product item) {
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
            style: const TextStyle(
              color: AppColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(Product item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.edit, color: AppColor.primary, size: 20),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: item.id),
          ));
        },
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
