import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ignore: must_be_immutable
class ProductList extends StatefulWidget {
  final Function(List<Map<String, Product>>) onProductSelected;
  VoidCallback? onCartScreenExit;

  ProductList({
    super.key,
    required this.onProductSelected,
    this.onCartScreenExit,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final _productService = ProductService();

  // Data state
  List<Product> _allMenuItems = [];
  List<Product> _filteredMenuItems = [];
  final Map<String, Product> _selectedProducts =
      {}; // Menggunakan Map untuk selected products
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Data fetching methods
  Future<void> _initializeData() async {
    try {
      await _fetchProducts();
    } catch (e) {
      _handleError('Failed to initialize data: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _productService.fetchProducts();
      if (!mounted) return;

      if (response.status) {
        setState(() {
          _allMenuItems = response.data!;
          _filteredMenuItems = _allMenuItems;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        _handleError(response.message);
      }
    } catch (e) {
      _handleError('Error fetching products: $e');
    }
  }

  // Error handling
  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
    _showMessage(message, isError: true);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Cart management methods
  void _updateCartQuantity(Product product, int newQuantity) {
    if (!mounted) return;

    setState(() {
      if (newQuantity <= 0) {
        // Hapus produk jika quantity 0 atau negatif
        _selectedProducts.remove(product.id);
      } else if (newQuantity <= product.stok) {
        // Buat copy baru dari product untuk menghindari referensi
        final updatedProduct = Product(
          id: product.id,
          namaProduk: product.namaProduk,
          hargaProduk: product.hargaProduk,
          stok: product.stok,
          fotoProduk: product.fotoProduk,
          kategori: '',
          slugProduk: '',
          status: '',
          mitraId: '',
        )..count = newQuantity;

        _selectedProducts[product.id] = updatedProduct;
      } else {
        _showMessage('Quantity melebihi stok yang tersedia!', isError: true);
        return;
      }

      // Notify parent widget about changes
      final selectedItems = _selectedProducts.entries
          .map((entry) => {entry.key: entry.value})
          .toList();
      widget.onProductSelected(selectedItems);
    });
  }

  int _getSelectedQuantity(String productId) {
    return _selectedProducts[productId]?.count ?? 0;
  }

  // Search functionality
  void _searchMenu(String query) {
    setState(() {
      _filteredMenuItems = query.isEmpty
          ? _allMenuItems
          : _allMenuItems
              .where((item) =>
                  item.namaProduk.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  // UI Building methods
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          SearchBar(onSearch: _searchMenu),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredMenuItems.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.builder(
      itemCount: _filteredMenuItems.length,
      itemBuilder: (context, index) =>
          _buildMenuItem(_filteredMenuItems[index]),
    );
  }

  Widget _buildMenuItem(Product item) {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _buildProductImage(imageUrl),
            const SizedBox(width: 16),
            Expanded(child: _buildProductInfo(item)),
            _buildQuantityControls(item),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {
        // Handle image loading error
      },
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
        const SizedBox(height: 4),
        Text(
          'Rp ${item.hargaProduk.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Stock: ${item.stok}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(Product item) {
    final quantity = _getSelectedQuantity(item.id);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.primary, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            Icons.remove,
            () => _updateCartQuantity(item, quantity - 1),
            enabled: quantity > 0,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          _buildControlButton(
            Icons.add,
            () => _updateCartQuantity(item, quantity + 1),
            enabled: item.stok > quantity,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(
          icon,
          color: enabled ? AppColor.primary : Colors.grey,
          size: 18,
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 40,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search menu...',
            prefixIcon: const Icon(Icons.search),
            border: _buildBorder(),
            enabledBorder: _buildBorder(),
            focusedBorder: _buildBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          ),
          onChanged: onSearch,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 183, 183, 183),
        width: 0.5,
      ),
    );
  }
}
