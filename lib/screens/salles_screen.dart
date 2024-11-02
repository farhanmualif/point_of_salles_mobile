import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:point_of_salles_mobile_app/models/cart_model.dart';
import 'package:point_of_salles_mobile_app/models/product_model.dart';
import 'package:point_of_salles_mobile_app/services/cart_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:point_of_salles_mobile_app/widgets/menu_list.dart';

class SallesScreen extends StatefulWidget {
  const SallesScreen({super.key});

  @override
  State<SallesScreen> createState() => _SallesScreenState();
}

class _SallesScreenState extends State<SallesScreen> {
  int selectedItemCount = 0;
  double totalPrice = 0.0;
  bool _isLoading = false;

  List<Cart> _carts = [];
  List<Map<String, Product>> _selectedProducts = [];

  final CartService _cartService = CartService();
  @override
  void initState() {
    fetchCart();
    super.initState();
  }

  void updateSelectedItems(int count, double price) {
    setState(() {
      selectedItemCount = count;
      totalPrice = price;
    });
  }

  void updateCartList(List<Cart> updatedCart) {
    setState(() {
      _carts = updatedCart;
    });
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

  Future<void> postCart(List<Map<String, Product>> products) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Konversi List<Map<String, Product>> menjadi List<Product>
      List<Product> productList =
          products.map((map) => map.values.first).toList();

      // Kirim data yang sudah dikonversi
      final response = await _cartService.postCart(productList);

      // Memperbarui cart setelah berhasil post
      if (response.status) {
        await fetchCart();
        _showMessage(response.message);
      } else {
        _showMessage(response.message, isError: true);
      }
    } catch (e) {
      _showMessage('Failed to update cart: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCart() async {
    try {
      var getCart = await _cartService.fetchCart();
      if (getCart.data != null) {
        _carts = getCart.data!;
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  void handleProductSelected(List<Map<String, Product>> products) {
    debugPrint("handle product selected");
    setState(() {
      _selectedProducts = products;

      selectedItemCount = _selectedProducts.length;
      totalPrice = _selectedProducts.fold(0.0, (total, item) {
        var product = item.values.first;
        return total + product.hargaProduk;
      });
    });
    debugPrint("$totalPrice");
  }

  int get getTotalPrice {
    return _carts[0].totalHarga;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppColor.primary)))
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
                    Navigator.of(context).pushNamed("/cart_screen");
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey[200]),
                    child: SvgPicture.asset(
                      "assets/icons/shopping-cart.svg",
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              color: const Color(0xfff6f6f6),
              child: MenuList(onProductSelected: handleProductSelected),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                // await postCart(_selectedProducts);
                if (!context.mounted) return;
                // List<Product> products = [];
                // for (var element in _selectedProducts) {
                //   products.addAll(element.values.toList());
                // }
                debugPrint(
                    'Selected Products: ${_selectedProducts.map((productMap) => productMap.values.map((product) => '${product.namaProduk}: Rp ${product.hargaProduk} Rp ${product.count}').join(', ')).join(', ')}');

                // Navigator.of(context).pushNamed("/cart_screen");
              },
              label: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _carts.isNotEmpty
                              ? Text('Rp ${_carts[0].totalHarga}',
                                  style: const TextStyle(color: Colors.white))
                              : const Text('Rp 0',
                                  style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        children: [
                          Text('Lanjut', style: TextStyle(color: Colors.white)),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    )
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
}

class SearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBar({super.key, required this.onSearch});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: ' Search menu...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 183, 183, 183),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 183, 183, 183),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 183, 183, 183),
                width: 0.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          ),
          onChanged: widget.onSearch,
        ),
      ),
    );
  }
}
