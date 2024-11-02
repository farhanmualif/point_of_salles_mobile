class Product {
  final String id;
  final String kategori;
  final String namaProduk;
  final String slugProduk;
  final String status;
  final int hargaProduk;
  final String? fotoProduk;
  final String mitraId;
  int count;
  final int stok; // New field for stock quantity

  Product({
    required this.id,
    required this.kategori,
    required this.namaProduk,
    required this.slugProduk,
    required this.status,
    required this.hargaProduk,
    this.fotoProduk,
    this.count = 0,
    required this.mitraId,
    this.stok = 0, // Default stock quantity
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      kategori: json['kategori'],
      namaProduk: json['namaProduk'],
      slugProduk: json['slugProduk'],
      status: json['status'],
      hargaProduk: json['hargaProduk'],
      fotoProduk: json['fotoProduk'],
      mitraId: json['mitraId'],
      stok: json['stok_produk'] != null
          ? json['stok_produk']['qty']
          : 0, // Extract stock quantity
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori': kategori,
      'namaProduk': namaProduk,
      'slugProduk': slugProduk,
      'status': status,
      'hargaProduk': hargaProduk,
      'fotoProduk': fotoProduk,
      'mitraId': mitraId,
      'count': count,
      'stok_produk': {
        'qty': stok, // Include stock quantity in nested JSON structure
      },
    };
  }
}
