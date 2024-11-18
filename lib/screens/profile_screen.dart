import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/models/base_response.dart';
import 'package:point_of_salles_mobile_app/models/profile.dart';
import 'package:point_of_salles_mobile_app/services/auth_service.dart';
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
  final AuthService _authService = AuthService(); // Tambahkan ini
  Karyawan? _profile;
  bool _isLoading = false;
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
        });
      } else {
        setState(() {
          _error = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan saat memuat profil';
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Tampilkan dialog konfirmasi
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Ya, Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        // Tampilkan loading indicator
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final response = await _authService.logout();

        // Tutup loading indicator
        if (!mounted) return;
        Navigator.of(context).pop();

        if (response.status) {
          // Jika logout berhasil, navigate ke splash screen
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/splash_screen', // Sesuaikan dengan route login Anda
            (route) => false,
          );
        } else {
          // Jika gagal, tampilkan pesan error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Tutup loading indicator
        if (!mounted) return;
        Navigator.of(context).pop();

        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat logout'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColor.primary)));
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
    return ListTile(
      leading: const Icon(Icons.exit_to_app, color: Colors.red),
      title: const Text('Logout', style: TextStyle(color: Colors.red)),
      onTap: _handleLogout, // Tambahkan handler
    );
  }
}
