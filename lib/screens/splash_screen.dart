import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/screens/login_screen.dart';
import 'package:point_of_salles_mobile_app/screens/main_screen.dart';
import 'package:point_of_salles_mobile_app/services/auth_service.dart';
import 'package:point_of_salles_mobile_app/services/secure_storage_service.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> authenticated() async {
    try {
      return await SecureStorageService.hasToken();
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

  Future<void> checkAuthAndNavigate() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      final AuthService authService = AuthService();
      final bool isAuthenticated = await authService.checkAuth();
  

      if (isAuthenticated) {
        debugPrint('authenticated');
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        debugPrint('unauthenticated');
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error in checkAuthAndNavigate: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo/logo.png',
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return const Icon(Icons.image_not_supported, size: 100);
              },
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 50,
              child: LinearProgressIndicator(color: AppColor.primary),
            ),
          ],
        ),
      ),
    );
  }
}
