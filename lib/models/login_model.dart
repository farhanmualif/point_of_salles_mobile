class UserData {
  final String nama;
  final String username;
  final String email;
  final String akses;
  final String aksesName;
  final String token;

  UserData({
    required this.nama,
    required this.username,
    required this.email,
    required this.akses,
    required this.aksesName,
    required this.token,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nama: json['nama'],
      username: json['username'],
      email: json['email'],
      akses: json['akses'],
      aksesName: json['akses_name'],
      token: json['token'],
    );
  }
}
