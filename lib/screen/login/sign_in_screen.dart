import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/home/choose_service_screen.dart';
import 'package:uytaza/screen/login/sign_up_screen.dart';
import 'package:uytaza/screen/login/temporary_password_change_screen.dart';

import '../home/home_screen.dart';
import '../main/main_tab_page.dart';
import 'api_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  bool isPasswordVisible = false;

  void _handleSignIn() async {
    final email = txtEmail.text.trim();
    final password = txtPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      final response = await ApiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        await ApiService.saveToken(token);

        // Check if password needs to be changed
        final validationResponse = await http.get(
          Uri.parse('${ApiService.baseUrl}/api/auth/validate'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (jsonDecode(validationResponse.body)['reset_required'] == true) {
          context.push(TemporaryPasswordChangeScreen());
        } else {
          context.push(MainTabPage());
        }
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset("assets/img/bg.png", fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset("assets/img/logo.png", width: context.width * 0.5),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: TColor.title,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RoundTextfield(
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        controller: txtEmail,
                      ),
                      const SizedBox(height: 16),
                      RoundTextfield(
                        hintText: "Password",
                        obscureText: !isPasswordVisible,
                        controller: txtPassword,
                        right: IconButton(
                          onPressed: () {
                            setState(
                                  () => isPasswordVisible = !isPasswordVisible,
                            );
                          },
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: TColor.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      RoundButton(
                        title: "SIGN IN",
                        fontWeight: FontWeight.bold,
                        onPressed: _handleSignIn,
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "Or Sign In with",
                        style: TextStyle(color: TColor.placeholder),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _handleGoogleSignIn,
                        child: Image.asset("assets/img/google.png", width: 50),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: TColor.primaryText),
                ),
                RoundButton(
                  title: "SIGN UP",
                  width: context.width * 0.65,
                  type: RoundButtonType.line,
                  onPressed: () => context.push(const SignUpScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleForgotPassword() async {
    final email = txtEmail.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first")),
      );
      return;
    }

    try {
      final response = await ApiService.post('/api/auth/resend-password', {
        'email': email,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Temporary password sent to your email"),
          ),
        );

        // Переход на экран смены пароля

        context.push(TemporaryPasswordChangeScreen());
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final response = await ApiService.post('/api/auth/google-login', {
        'id_token': googleAuth.idToken,
      });

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        await ApiService.saveToken(token);

        context.push(MainTabPage());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }
}