class DetailTransaction {
  final String id;
  final String transaksiId;
  final String idProduk;
  final String namaProduk;
  final int hargaProduk;
  final int qtyProduk;

  DetailTransaction({
    required this.id,
    required this.transaksiId,
    required this.idProduk,
    required this.namaProduk,
    required this.hargaProduk,
    required this.qtyProduk,
  });

  factory DetailTransaction.fromJson(Map<String, dynamic> json) {
    return DetailTransaction(
      id: json['id'],
      transaksiId: json['transaksiId'],
      idProduk: json['idProduk'],
      namaProduk: json['namaProduk'],
      hargaProduk: json['hargaProduk'],
      qtyProduk: json['qtyProduk'],
    );
  }
}