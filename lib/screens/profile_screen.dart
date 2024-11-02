import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/profile_image.png'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Coffeestories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'mark.brock@icloud.com',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
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
                _buildListTile('Coffeestories', '', Icons.person),
                _buildListTile('+62 834657835', '', Icons.phone),
                _buildListTile('Yogyakarta', '', Icons.home),
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
