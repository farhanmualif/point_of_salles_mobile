import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/screens/menu_screen.dart';
import 'package:point_of_salles_mobile_app/screens/new_salles_screen.dart';
import 'package:point_of_salles_mobile_app/screens/profile_screen.dart';
import 'package:point_of_salles_mobile_app/screens/salles_history.dart';
import 'package:point_of_salles_mobile_app/screens/stock_produk_screen.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:point_of_salles_mobile_app/screens/products_screen.dart';
import 'package:point_of_salles_mobile_app/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  int? userAccess;

  @override
  void initState() {
    super.initState();
    _checkUserAccess();
  }

  Future<void> _checkUserAccess() async {
    final access = await _authService.getUserAccess();
    setState(() {
      userAccess = access;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan screens berdasarkan user access
    final List<Widget> screens = userAccess == 2
        ? [
            const MenuScreen(),
            const ProductsScreen(),
            const StockProductScreen(),
            const ProfileScreen(),
          ]
        : [
            const MenuScreen(),
            const NewSallesScreen(),
            const SallesHistory(),
            const ProfileScreen(),
          ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        userAccess: userAccess,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int? userAccess;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.userAccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColor.primary,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_cart_outlined),
                activeIcon: const Icon(Icons.shopping_cart),
                label: userAccess == 2 ? 'Produk' : 'Jual',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: userAccess == 2 ? 'Stok' : 'Riwayat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
