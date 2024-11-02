class UserData {
  final String nama;
  final String username;
  final String email;
  final String token;

  UserData({
    required this.nama,
    required this.username,
    required this.email,
    required this.token,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nama: json['nama'],
      username: json['username'],
      email: json['email'],
      token: json['token'],
    );
  }
}