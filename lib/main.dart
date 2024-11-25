import 'package:flutter/material.dart';
import 'package:point_of_salles_mobile_app/screens/add_product_form.dart';
import 'package:point_of_salles_mobile_app/screens/cart_screen.dart';
import 'package:point_of_salles_mobile_app/screens/edit_product_screen.dart';
import 'package:point_of_salles_mobile_app/screens/login_screen.dart';
import 'package:point_of_salles_mobile_app/screens/main_screen.dart';
import 'package:point_of_salles_mobile_app/screens/payment_screen.dart';
import 'package:point_of_salles_mobile_app/screens/payment_success.dart';
import 'package:point_of_salles_mobile_app/screens/splash_screen.dart';
import 'package:point_of_salles_mobile_app/screens/stock_produk_screen.dart';
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
      title: 'Point of Sales',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/main_screen": (context) => const MainScreen(),
        "/login_screen": (context) => const LoginScreen(),
        "/splash_screen": (context) => const SplashScreen(),
        "/cart_screen": (context) => const CartScreen(),
        "/payment_screen": (context) => const PaymentScreen(),
        "/add_product_form": (context) => const AddProductForm(),
        "/stock_product_screen": (context) => const StockProductScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/payment_success':
            final data = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(data: data),
            );
          case '/edit_profile_screen':
            final args = settings.arguments as Map<String, dynamic>;
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
        primarySwatch: MaterialColor(AppColor.primary.value, {
          50: AppColor.primary.withOpacity(0.1),
          100: AppColor.primary.withOpacity(0.2),
          200: AppColor.primary.withOpacity(0.3),
          300: AppColor.primary.withOpacity(0.4),
          400: AppColor.primary.withOpacity(0.5),
          500: AppColor.primary.withOpacity(0.6),
          600: AppColor.primary.withOpacity(0.7),
          700: AppColor.primary.withOpacity(0.8),
          800: AppColor.primary.withOpacity(0.9),
          900: AppColor.primary,
        }),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          primary: AppColor.primary,
          secondary: AppColor.primary,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          prefixIconColor: AppColor.primary,
          suffixIconColor: Colors.grey[600],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColor.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.5,
            ),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black87,
            size: 24,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
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
