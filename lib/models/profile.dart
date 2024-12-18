class User {
  final String id;
  final String nama;
  final String username;
  final String email;
  final String? foto;
  final String akses;
  final String active;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    this.foto,
    required this.akses,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      username: json['username'],
      email: json['email'],
      foto: json['foto'],
      akses: json['akses'],
      active: json['active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Karyawan {
  final String id;
  final String userId;
  final String mitraId;
  final String nomorHpAktif;
  final String alamat;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User user;

  Karyawan({
    required this.id,
    required this.userId,
    required this.mitraId,
    required this.nomorHpAktif,
    required this.alamat,
    this.createdAt,
    this.updatedAt,
    required this.user,
  });

  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      id: json['id'],
      userId: json['userId'],
      mitraId: json['mitraId'],
      nomorHpAktif: json['nomorHpAktif'],
      alamat: json['alamat'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: User.fromJson(json['user']),
    );
  }
}
