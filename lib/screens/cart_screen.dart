import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/cart_model.dart';
import 'package:point_of_salles_mobile_app/services/cart_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:point_of_salles_mobile_app/widgets/checkout_bottom_sheet.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<Cart> _cartItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  Future<void> _fetchCartData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _cartService.fetchCart();
      if (response.status) {
        setState(() {
          _cartItems = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteCart() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _cartService.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Hapus Keranjang'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fixed total calculation to use actual item totals
  double get total => _cartItems.fold(
      0,
      (sum, item) =>
          sum +
          item.details
              .fold(0, (sum, detail) => sum + detail.harga * detail.qty));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await deleteCart();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'My Cart',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primary))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItemWidget(
                        item: _cartItems[index],
                        onQuantityChanged: (newQuantity, detailIndex) {
                          setState(() {
                            // Update quantity for specific detail
                            _cartItems[index].details[detailIndex].qty =
                                newQuantity;
                            // Recalculate total for the cart item
                            _cartItems[index].totalHarga = _cartItems[index]
                                .details
                                .fold(
                                    0,
                                    (sum, detail) =>
                                        sum + (detail.harga * detail.qty));
                          });
                        },
                        onDeleteItem: () {
                          setState(() {
                            _cartItems.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: SafeArea(
                    child: Row(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'IDR ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    CheckoutBottomSheet(totalPayment: total),
                              );
                            },
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final Cart item;
  final Function(int, int) onQuantityChanged;
  final VoidCallback onDeleteItem;
  final String? apiUrl = dotenv.env['API_URL'];

  CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: item.details.asMap().entries.map((entry) {
          final int index = entry.key;
          final detail = entry.value;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: detail.produk.fotoProduk != null
                              ? NetworkImage(
                                  '$apiUrl/produk_thumbnail/${detail.produk.fotoProduk}')
                              : NetworkImage(
                                  '$apiUrl/produk_thumbnail/thumbnail_1.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.produk.namaProduk,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'IDR ${detail.harga.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'IDR ${(detail.harga * detail.qty).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     _QuantityButton(
                        //       icon: Icons.remove,
                        //       onPressed: () {
                        //         if (detail.qty > 1) {
                        //           onQuantityChanged(detail.qty - 1, index);
                        //         }
                        //       },
                        //     ),
                        //     Padding(
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 8),
                        //       child: Text(
                        //         '${detail.qty}',
                        //         style: const TextStyle(fontSize: 13),
                        //       ),
                        //     ),
                        //     _QuantityButton(
                        //       icon: Icons.add,
                        //       onPressed: () {
                        //         onQuantityChanged(detail.qty + 1, index);
                        //       },
                        //     ),
                        //   ],
                        // ),
                        IconButton(
                          onPressed: onDeleteItem,
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (index < item.details.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Icon(icon, size: 14, color: Colors.grey[600]),
      ),
    );
  }
}
