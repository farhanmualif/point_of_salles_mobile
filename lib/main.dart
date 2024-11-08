import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/screens/cart_screen.dart';
import 'package:point_of_salles_mobile_app/screens/login_screen.dart';
import 'package:point_of_salles_mobile_app/screens/main_screen.dart';
import 'package:point_of_salles_mobile_app/screens/payment_screen.dart';
import 'package:point_of_salles_mobile_app/screens/payment_success.dart';
import 'package:point_of_salles_mobile_app/screens/splash_screen.dart';
import 'package:point_of_salles_mobile_app/screens/update_profile.dart';
import 'package:point_of_salles_mobile_app/themes/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ErrorBoundary(
    child: MyApp(),
  ));
}

// Tambahkan Error Boundary Widget
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          // Tangkap error yang mungkin terjadi
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Material(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Terjadi Error!',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    Text(errorDetails.exception.toString()),
                  ],
                ),
              ),
            );
          };
          return child;
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/main_screen": (context) => const MainScreen(),
        "/login_screen": (context) => const LoginScreen(),
        "/splash_screen": (context) => const SplashScreen(),
        "/cart_screen": (context) => const CartScreen(),
        "/payment_screen": (context) => const PaymentScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/payment_success':
            final data = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(data: data),
            );
          case '/edit_profile_screen':
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (context) => EditProfilePage(
                username: args['username'] ?? '',
                email: args['email'] ?? '',
                noHp: args['noHp'] ?? '',
                alamat: args['alamat'] ?? '',
                karyawanId: args['karyawanId'] ?? '',
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const ErrorScreen(
                message: "Page not found",
              ),
            );
        }
      },
      theme: ThemeData(
        primaryColor: AppColor.primary,
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
        ).copyWith(error: Colors.redAccent),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
