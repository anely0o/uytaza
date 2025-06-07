import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/login/temporary_password_change_screen.dart';
import 'package:uytaza/api/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtEmail = TextEditingController();

  void _handleSignUp() async {
    if (txtFirstName.text.isEmpty ||
        txtLastName.text.isEmpty ||
        txtEmail.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    try {
      final response = await ApiService.post('/api/auth/register', {
        'first_name': txtFirstName.text.trim(),
        'last_name': txtLastName.text.trim(),
        'email': txtEmail.text.trim(),
      });

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        await ApiService.saveToken(token);
        context.push(const TemporaryPasswordChangeScreen());
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Container(color: TColor.background),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              children: [
                Image.asset("assets/img/logo.png",
                    width: context.width * 0.5),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: TColor.softShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: TColor.title,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RoundTextfield(
                        hintText: "First Name",
                        controller: txtFirstName,
                      ),
                      const SizedBox(height: 10),
                      RoundTextfield(
                        hintText: "Last Name",
                        controller: txtLastName,
                      ),
                      const SizedBox(height: 10),
                      RoundTextfield(
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        controller: txtEmail,
                      ),
                      const SizedBox(height: 20),
                      RoundButton(
                        title: "SIGN UP",
                        backgroundColor: TColor.primary,
                        textColor: Colors.white,
                        fontWeight: FontWeight.bold,
                        onPressed: _handleSignUp,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Already have an account?",
                  style: TextStyle(color: TColor.textPrimary),
                ),
                const SizedBox(height: 8),
                RoundButton(
                  title: "SIGN IN",
                  width: context.width * 0.65,
                  type: RoundButtonType.line,
                  textColor: TColor.primary,
                  lineColor: TColor.primary,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
