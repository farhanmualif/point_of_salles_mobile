import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/services/cart_service.dart';
import 'package:point_of_salles_mobile_app/services/product_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewSallesScreen extends StatefulWidget {
  const NewSallesScreen({super.key});

  @override
  State<NewSallesScreen> createState() => _NewSallesScreenState();
}

class _NewSallesScreenState extends State<NewSallesScreen> {
  int selectedItemCount = 0;
  double totalPrice = 0.0;
  bool isLoading = false;

  List<Map<String, Product>> selectedProducts = [];
  List<Product> filteredMenuItems = [];
  List<Product> allMenuItems = [];
  final CartService _cartService = CartService();

  final ProductService productService = ProductService();

  TextEditingController searchbarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts(); // Fetch products on initialization
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

  void updateSelectedItems(int count, double price) {
    setState(() {
      selectedItemCount = count;
      totalPrice = price;
    });
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

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void handleProductSelection(List<Map<String, Product>> products) {
    setState(() {
      selectedProducts = products;
      selectedItemCount = selectedProducts.length;
      totalPrice = selectedProducts.fold(0.0, (total, item) {
        var product = item.values.first;
        return total + product.hargaProduk;
      });
    });
  }

  Future<void> postCart(List<Map<String, Product>> products) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Konversi List<Map<String, Product>> menjadi List<Product>
      List<Product> productList =
          products.map((map) => map.values.first).toList();

      // Kirim data yang sudah dikonversi
      final response = await _cartService.postCart(productList);

      // Memperbarui cart setelah berhasil post
      if (!response.status) {
        _showMessage(response.message, isError: true);
      }
    } catch (e) {
      _showMessage('Failed to update cart: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                'Menu',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    postCart(selectedProducts).then((response) {
                      Navigator.of(context).pushNamed("/cart_screen");
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey[200],
                    ),
                    child: SvgPicture.asset("assets/icons/shopping-cart.svg",
                        width: 18, height: 18),
                  ),
                ),
              ],
            ),
            body: Container(
              color: const Color(0xfff6f6f6),
              child: buildMenu(),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                postCart(selectedProducts).then((response) {
                  Navigator.of(context).pushNamed("/cart_screen");
                });
              },
              label: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Rp ${NumberFormat('#,##0', 'id_ID').format(calculateTotalPrice())}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        children: [
                          Text('Lanjut', style: TextStyle(color: Colors.white)),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: AppColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
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
            buildQuantityControls(item),
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
        const SizedBox(height: 4),
        Text('Stock: ${item.stok}',
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget buildQuantityControls(Product item) {
    final quantity = getSelectedQuantity(item.id);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: AppColor.primary, width: 1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildControlButton(
              Icons.remove, () => updateCartQuantity(item, quantity - 1),
              enabled: quantity > 0),
          Container(
              constraints: const BoxConstraints(minWidth: 30),
              alignment: Alignment.center,
              child: Text('$quantity',
                  style: const TextStyle(
                      color: AppColor.primary, fontWeight: FontWeight.bold))),
          buildControlButton(
              Icons.add, () => updateCartQuantity(item, quantity + 1),
              enabled: item.stok > quantity),
        ],
      ),
    );
  }

  Widget buildControlButton(IconData icon, VoidCallback onPressed,
      {bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(icon,
            color: enabled ? AppColor.primary : Colors.grey, size: 18),
      ),
    );
  }

  int getSelectedQuantity(String productId) {
    for (var productMap in selectedProducts) {
      if (productMap.containsKey(productId)) {
        return productMap[productId]!.count; // Adjusted to ensure proper access
      }
    }
    return 0;
  }

  void updateCartQuantity(Product product, int newQuantity) {
    if (!mounted) return;

    setState(() {
      if (newQuantity <= 0) {
        selectedProducts
            .removeWhere((productMap) => productMap.containsKey(product.id));
      } else if (newQuantity <= product.stok) {
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

        bool productExists = false;

        for (var productMap in selectedProducts) {
          if (productMap.containsKey(product.id)) {
            productMap[product.id] = updatedProduct;
            productExists = true;
            break;
          }
        }

        if (!productExists) {
          selectedProducts.add({product.id: updatedProduct});
        }
      } else {
        showMessage('Quantity exceeds available stock!', isError: true);
      }

      // Memperbarui total price setiap kali ada perubahan
      totalPrice = calculateTotalPrice();
    });
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var productMap in selectedProducts) {
      var product = productMap.values.first;
      total += product.hargaProduk * product.count;
    }
    return total;
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
