import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/login/temporary_password_change_screen.dart';
import '../../api/api_service.dart';

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
        context.push(TemporaryPasswordChangeScreen());
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: TColor.title,
                        ),
                      ),
                      const SizedBox(height: 16),
                      NewRoundTextfield(
                        hintText: "First Name",
                        controller: txtFirstName,
                      ),
                      const SizedBox(height: 10),
                      NewRoundTextfield(
                        hintText: "Last Name",
                        controller: txtLastName,
                      ),
                      const SizedBox(height: 10),
                      NewRoundTextfield(
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        controller: txtEmail,
                      ),
                      const SizedBox(height: 20),
                      RoundButton(
                        title: "SIGN UP",
                        fontWeight: FontWeight.bold,
                        onPressed: _handleSignUp,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Or Sign Up with",
                        style: TextStyle(color: TColor.placeholder),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          // TODO: Google Sign-Up
                        },
                        child: Image.asset("assets/img/google.png", width: 50),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Already have an account?",
                  style: TextStyle(color: TColor.primaryText),
                ),
                RoundButton(
                  title: "SIGN IN",
                  width: context.width * 0.65,
                  type: RoundButtonType.line,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}