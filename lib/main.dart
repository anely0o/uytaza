import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/login/splash_screen.dart';
import 'package:uytaza/screen/main/main_tab_page.dart';
import 'package:uytaza/screen/profile/rate_of_service_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UyTaza',
      theme: ThemeData(
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
      ),
      home: const SplashScreen(),
    );
  }
}
