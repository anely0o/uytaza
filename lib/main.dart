import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/login/splash_screen.dart';
import 'package:uytaza/screen/main/main_tab_page.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/screen/models/subscription_model.dart';
import 'package:uytaza/screen/order/client/order_build_page.dart';
import 'package:uytaza/screen/order/client/order_edit_page.dart';
import 'package:uytaza/screen/subscription/subscription_build_page.dart';
import 'package:uytaza/screen/profile/rate_of_service_screen.dart';
import 'package:uytaza/screen/subscription/subscription_edit_page.dart';
import 'package:uytaza/screen/subscription/subscriptions_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UyTaza',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
      ),


      initialRoute: '/',
      routes: {
        '/':            (_) => const SplashScreen(),              // стартовый экран
        '/main':        (_) => const MainTabPage(),               // нижняя навигация
        '/new-order':   (_) => const OrderBuildPage(),            // создание разового заказа
        '/new-sub':     (_) => const SubscriptionBuildPage(),     // создание подписки
        '/rating':      (_) => const RateOfServiceScreen(),       // рейтинг клиента/клинера
        '/subs'        : (_) => const SubscriptionsScreen(),
        '/subs/edit'   : (ctx) {
          final sub = ModalRoute.of(ctx)!.settings.arguments as Subscription;
          return SubscriptionEditPage(subscription: sub);
        },
        '/order/edit': (ctx) {
          final orderId = ModalRoute.of(ctx)!.settings.arguments as String;
          return OrderEditPage(orderId: orderId);
        },
      },


      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text(
              'Route "${settings.name}" not found',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
