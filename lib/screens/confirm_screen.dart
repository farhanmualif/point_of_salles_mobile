import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  int selectedItemCount = 0;
  double totalPrice = 0.0;

  void updateSelectedItems(int count, double price) {
    setState(() {
      selectedItemCount = count;
      totalPrice = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9F9),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Confirm Transaction',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: Container(
          color: const Color(0xfff6f6f6),
          child: const ConfirmMenuList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to confirmation page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfirmScreen()),
            );
          },
          label: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: const Row(
              children: [
                Expanded(
                    flex: 7,
                    child: Row(
                      children: [
                        Text('Bayar', style: TextStyle(color: Colors.white)),
                      ],
                    )),
                Expanded(
                    child: Row(
                  children: [
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ))
              ],
            ),
          ),
          backgroundColor: AppColor.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ));
  }
}

class ConfirmMenuList extends StatefulWidget {
  const ConfirmMenuList({super.key});

  @override
  State<ConfirmMenuList> createState() => _ConfirmMenuListState();
}

class _ConfirmMenuListState extends State<ConfirmMenuList> {
  final List<Map<String, dynamic>> _allMenuItems = [
    {
      'name': 'Seared Scallops with Quinoa',
      'price': '139.000 đ',
      'image': 'https://example.com/scallops.jpg',
      'count': 0,
    },
    {
      'name': 'Caesar salad croquettes',
      'price': '230.000 đ',
      'image': 'https://example.com/caesar_salad.jpg',
      'count': 0,
    },
    {
      'name': 'Croque de luxe met steak',
      'price': '146.000 đ',
      'image': 'https://example.com/croque.jpg',
      'count': 0,
    },
    {
      'name': 'Wagyu and Pearls',
      'price': '398.000 đ',
      'image': 'https://example.com/wagyu.jpg',
      'count': 0,
    },
  ];

  List<Map<String, dynamic>> _filteredMenuItems = [];

  @override
  void initState() {
    super.initState();
    _filteredMenuItems = _allMenuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _filteredMenuItems.isEmpty
              ? const Center(
                  child: Text(
                      'No items found')) // Show a message when no items are found
              : ListView.builder(
                  itemCount: _filteredMenuItems.length,
                  itemBuilder: (context, index) =>
                      _buildMenuItem(_filteredMenuItems[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(item['image']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['price'],
                    style: const TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ghi chú',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: null,
                    icon: Icon(Icons.delete, color: Colors.red))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
