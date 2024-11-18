import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:point_of_salles_mobile_app/models/transaction.dart';
import 'package:point_of_salles_mobile_app/screens/menu_screen.dart';
import 'package:point_of_salles_mobile_app/screens/new_salles_screen.dart';
import 'package:point_of_salles_mobile_app/screens/profile_screen.dart';
import 'package:point_of_salles_mobile_app/screens/salles_history.dart';
import 'package:point_of_salles_mobile_app/services/transaction_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final TransactionService _transactionService = TransactionService();
  Transaction? _transaksi;
  bool _isLoading = true;

  final List<Widget> _screens = [
    const MenuScreen(),
    const NewSallesScreen(),
    const SallesHistory(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadPendingTransaction();
  }

  Future<void> _loadPendingTransaction() async {
    try {
      final response = await _transactionService.getPendingTransaction();
      setState(() {
        if (response.status && response.data != null) {
          _transaksi = response.data;
        } else {}
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadPendingTransaction();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    var splited = _transaksi?.paymentChannel?.split("_");

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      floatingActionButton: _transaksi != null
          ? FloatingActionButton.extended(
              heroTag: null, // Menggunakan UniqueKey untuk memastikan keunikan
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/payment_screen",
                  arguments: _transaksi,
                );
              },
              label: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          const Text(
                            "Menunggu Pembayaran",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _transaksi!.paymentChannel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Bayar',
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: AppColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildBottomNavigationBarItem('assets/icons/home.svg', 'Home', 0),
        _buildBottomNavigationBarItem(
            'assets/icons/shopping-bag.svg', 'Penjualan', 1),
        _buildBottomNavigationBarItem('assets/icons/repeat.svg', 'History', 2),
        _buildBottomNavigationBarItem(
            'assets/icons/user.svg', 'Profile saya', 3),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: AppColor.primary,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      String iconPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: ColorFiltered(
        colorFilter: ColorFilter.mode(
          selectedIndex == index ? AppColor.primary : Colors.grey,
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset(
          iconPath,
          height: 24,
          width: 24,
        ),
      ),
      label: label,
    );
  }
}
