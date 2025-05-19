import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/screen/login/sign_in_screen.dart';
import 'package:uytaza/screen/login/temporary_password_change_screen.dart';

import '../home/home_screen.dart';
import 'api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO implement init
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
          context.push(
            TemporaryPasswordChangeScreen(user: null, onUpdateUser: (user) {}),
          );
        } else {
          context.push(HomeScreen(user: null, onUpdateUser: (user) {}));
        }
      } else {
        goToAuth();
      }
    } catch (e) {
      goToAuth();
    }
  }//changed

  void goToAuth() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  void goStart() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        "assets/img/splash.png",
        width: context.width,
        height: context.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
