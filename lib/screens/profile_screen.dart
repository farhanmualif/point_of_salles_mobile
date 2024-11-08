import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/profile.dart';
import 'package:point_of_salles_mobile_app/services/profile_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final KaryawanService _karyawanService = KaryawanService();
  Karyawan? _profile;
  bool _isLoading = true;
  String _error = '';

  final String? baseUrl = dotenv.env['API_URL'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      // Assuming you have a way to get the current user's ID
      String userId = 'current_user_id'; // Replace with actual user ID
      BaseResponse<Karyawan> response =
          await _karyawanService.fetchProfile(userId);
      if (response.status) {
        setState(() {
          _profile = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan saat memuat profil';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _profile?.user.foto != null
                    ? NetworkImage("$baseUrl/${_profile!.user.foto}")
                    : const AssetImage('assets/images/default-user.png')
                        as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                _profile?.user.nama ?? '',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                _profile?.user.email ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/edit_profile_screen',
                    arguments: {
                      'username': _profile!.user.username,
                      'email': _profile!.user.email,
                      'noHp': _profile!.nomorHpAktif,
                      'alamat': _profile!.alamat,
                      'karyawanId': _profile!.id
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Edit profile',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
              _buildSection('Profile', [
                _buildListTile(_profile?.user.nama ?? '', '', Icons.person),
                _buildListTile(_profile?.nomorHpAktif ?? '', '', Icons.phone),
                _buildListTile(_profile?.alamat ?? '', '', Icons.home),
              ]),
              const SizedBox(height: 16),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, String trailing, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColor.primary),
      title: Text(title),
      trailing: trailing.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Text(
                trailing,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _buildLogoutButton() {
    return const ListTile(
      leading: Icon(Icons.exit_to_app, color: Colors.red),
      title: Text('Logout', style: TextStyle(color: Colors.red)),
    );
  }
}
