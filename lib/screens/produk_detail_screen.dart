import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/screens/edit_product_screen.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  final ProductService _productService = ProductService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true;
    });

    Product? getProduct = await _fetchProduct();
    if (mounted) {
      setState(() {
        _product = getProduct;
        _isLoading = false;
      });
    }
  }

  Future<Product?> _fetchProduct() async {
    final response = await _productService.getProductById(widget.productId);
    if (response.status) {
      return response.data;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal mengambil detail produk'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  void _toggleProductStatus() async {
    if (_product == null) return;

    try {
      final response = await _productService.updateProductStatus(
        productId: _product!.id,
      );

      if (response.status) {
        // Refresh product data
        final updatedProduct = await _fetchProduct();

        if (mounted) {
          setState(() {
            _product = updatedProduct;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Gagal mengubah status produk'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProductActive = _product?.status == "1";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Produk tidak ditemukan'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(),
                      _buildProductDetails(isProductActive),
                    ],
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Detail Produk',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          _product!.fotoProduk != null
              ? '${dotenv.env['API_URL']}/produk_thumbnail/${_product!.fotoProduk}'
              : '${dotenv.env['API_URL']}/produk_thumbnail/thumbnail_1.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductDetails(bool isProductActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(isProductActive),
          const SizedBox(height: 20),
          _buildProductName(),
          const SizedBox(height: 16),
          _buildProductInfo(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isProductActive) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.shopping_bag, color: Colors.blue, size: 16),
              SizedBox(width: 4),
              Text(
                'PRODUCT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildStatusSwitch(isProductActive),
        _buildEditButton(),
      ],
    );
  }

  Widget _buildStatusSwitch(bool isProductActive) {
    return Column(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: isProductActive,
            onChanged:
                _isLoading ? null : (bool value) => _toggleProductStatus(),
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
          ),
        ),
        Text(
          isProductActive ? 'Aktif' : 'Tidak Aktif',
          style: TextStyle(
            fontSize: 11,
            color: isProductActive ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditProductScreen(product: _product!),
          ),
        );
      },
      icon: const Icon(Icons.edit, size: 16),
      label: const Text('Edit'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      _product!.namaProduk,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Stok', '${_product!.stok}'),
          const SizedBox(height: 8),
          _buildInfoRow('Harga', 'Rp. ${_product!.hargaProduk}'),
          const SizedBox(height: 8),
          _buildInfoRow('Kategori', _product!.kategori),
          const SizedBox(height: 8),
          _buildInfoRow('Status Stok', _product!.statusStok),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
