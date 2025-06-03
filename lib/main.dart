// lib/main.dart
import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/history/history_screen.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/login/splash_screen.dart';
import 'package:uytaza/screen/main/main_tab_page.dart';
import 'package:uytaza/screen/order/client/orders_screen.dart';
import 'package:uytaza/screen/profile/rate_of_service_screen.dart';
import 'package:uytaza/screen/subscription/subscription_build_page.dart';
import 'package:uytaza/screen/subscription/subscriptions_screen.dart';
import 'package:uytaza/screen/subscription/subscription_edit_page.dart';
import 'package:uytaza/screen/models/subscription_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UyTaza',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        scaffoldBackgroundColor: Colors.white,

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: TColor.primary),
          titleTextStyle: TextStyle(
            color: TColor.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          elevation: 0.5,
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: TColor.primary,
          unselectedItemColor: TColor.textSecondary,
        ),
      ),

      // The initial route remains the splash screen
      initialRoute: '/',

      // All “simple” (no‐argument) pages can be listed here:
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/main': (context) => const MainTabPage(),
        '/rate': (context) => const RateOfServiceScreen(),
        '/order': (context) => const OrdersScreen(),
        '/new-sub': (context) => const SubscriptionBuildPage(),
        '/subscriptions': (context) => const SubscriptionsScreen(),
        '/history': (ctx) => const HistoryScreen(),
      },

      // onGenerateRoute will catch any route that needs an argument,
      // for example: "/subs/edit" expects a Subscription object in arguments.
      onGenerateRoute: (settings) {
        if (settings.name == '/subs/edit') {
          final args = settings.arguments;
          if (args is Subscription) {
            return MaterialPageRoute(
              builder: (_) => SubscriptionEditPage(subscription: args),
            );
          }
          // If we get here, it means arguments were missing or wrong type.
          return _errorRoute("Missing or invalid subscription data.");
        }

        // If no match was found in routes or onGenerateRoute, return null
        // so Flutter will throw a “Could not find a generator for route” exception.
        return null;
      },
    );
  }

  // A simple “error” page if arguments are missing or invalid:
  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: TColor.primary),
        ),
        body: Center(
          child: Text(
            message,
            style: TextStyle(color: TColor.textSecondary, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
