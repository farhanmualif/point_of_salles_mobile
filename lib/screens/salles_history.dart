import 'package:flutter/material.dart';

class SallesHistory extends StatelessWidget {
  SallesHistory({super.key});

  // Data dummy
  final List<Map<String, dynamic>> salesData = [
    {
      'image':
          'https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'name': 'Caramel Coffee Jelly Frappuccino',
      'invoiceId': '348653486',
      'customerName': 'John Doe',
      'quantity': 2,
      'price': 50000,
      'paymentType': 'BCA',
    },
    {
      'image':
          'https://images.pexels.com/photos/1193335/pexels-photo-1193335.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'name': 'Matcha Green Tea Latte',
      'invoiceId': '348653487',
      'customerName': 'Jane Smith',
      'quantity': 1,
      'price': 45000,
      'paymentType': 'OVO',
    },
    {
      'image':
          'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'name': 'Classic Espresso',
      'invoiceId': '348653488',
      'customerName': 'Bob Johnson',
      'quantity': 3,
      'price': 35000,
      'paymentType': 'GOPAY',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: salesData.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final item = salesData[index];
          return SallesHistoryItem(
            image: item['image'],
            name: item['name'],
            invoiceId: item['invoiceId'],
            customerName: item['customerName'],
            quantity: item['quantity'],
            price: item['price'],
            paymentType: item['paymentType'],
          );
        },
      ),
    );
  }
}

class SallesHistoryItem extends StatelessWidget {
  final String image;
  final String name;
  final String invoiceId;
  final String customerName;
  final int quantity;
  final int price;
  final String paymentType;

  const SallesHistoryItem({
    super.key,
    required this.image,
    required this.name,
    required this.invoiceId,
    required this.customerName,
    required this.quantity,
    required this.price,
    required this.paymentType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text("Invoice Id: $invoiceId"),
                Text("Nama Customer: $customerName"),
                Text("Kuantitas: $quantity"),
                Text("Harga: Rp. $price"),
                Text("Tipe Pembayaran: $paymentType"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total: Rp. $price',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
