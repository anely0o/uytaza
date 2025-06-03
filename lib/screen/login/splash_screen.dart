import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/login/sign_in_screen.dart';
import '../../api/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loadView();
  }

  void loadView() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await ApiService.getToken();
    if (token != null) {
      goToAuth();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/auth/validate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['reset_required'] == true) {
          context.push(const SignInScreen());
        } else {
          context.push(const HomeScreen());
        }
      } else {
        goToAuth();
      }
    } catch (e) {
      goToAuth();
    }
  }

  void goToAuth() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: Center(
        child: Image.asset(
          "assets/img/logo.png",
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
