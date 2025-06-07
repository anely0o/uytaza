import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/login/sign_up_screen.dart';
import 'package:uytaza/screen/login/temporary_password_change_screen.dart';
import 'package:uytaza/api/api_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  bool isPasswordVisible = false;

  // ────────── EMAIL / PASSWORD ──────────
  Future<void> _handleSignIn() async {
    final email = txtEmail.text.trim();
    final password = txtPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _show('Please enter email and password');
      return;
    }

    try {
      final res = await ApiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200) {
        final token = jsonDecode(res.body)['token'];
        await ApiService.saveToken(token);

        final vRes = await http.get(
          Uri.parse('${ApiService.baseUrl}/api/auth/validate'),
          headers: {'Authorization': 'Bearer $token'},
        );

        final reset = jsonDecode(vRes.body)['reset_required'] == true;

        if (reset) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const TemporaryPasswordChangeScreen(),
            ),
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
        }
      } else {
        _show(jsonDecode(res.body)['error'] ?? 'Error');
      }
    } catch (e) {
      _show('Login failed: $e');
    }
  }

  // ────────── FORGOT PASSWORD ──────────
  Future<void> _handleForgotPassword() async {
    final email = txtEmail.text.trim();

    if (email.isEmpty) {
      _show('Please enter your email first');
      return;
    }

    try {
      final res = await ApiService.post('/api/auth/resend-password', {
        'email': email,
      });

      if (res.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TemporaryPasswordChangeScreen(),
          ),
        );
      } else {
        _show(jsonDecode(res.body)['error'] ?? 'Error');
      }
    } catch (e) {
      _show('Failed: $e');
    }
  }


  // ────────── UI ──────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              children: [
                Image.asset('assets/img/logo.png',
                    width: context.width * 0.5),
                const SizedBox(height: 20),
                _buildCard(context),
                const SizedBox(height: 10),
                Text('Don\'t have an account?',
                    style: TextStyle(color: TColor.textPrimary)),
                const SizedBox(height: 8),
                RoundButton(
                  title: 'SIGN UP',
                  width: context.width * 0.65,
                  type: RoundButtonType.line,
                  textColor: TColor.primary,
                  lineColor: TColor.primary,
                  onPressed: () => context.push(const SignUpScreen()),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext ctx) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: TColor.softShadow,
    ),
    child: Column(
      children: [
        Text('Sign In',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: TColor.title)),
        const SizedBox(height: 16),
        RoundTextfield(
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          controller: txtEmail,
        ),
        const SizedBox(height: 16),
        RoundTextfield(
          hintText: 'Password',
          obscureText: !isPasswordVisible,
          controller: txtPassword,
          right: IconButton(
            onPressed: () =>
                setState(() => isPasswordVisible = !isPasswordVisible),
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: TColor.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            child: Text('Forgot Password?',
                style: TextStyle(
                    color: TColor.primary, fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(height: 10),
        RoundButton(
          title: 'SIGN IN',
          fontWeight: FontWeight.bold,
          backgroundColor: TColor.primary,
          textColor: Colors.white,
          onPressed: _handleSignIn,
        ),
      ],
    ),
  );

  // ────────── helper ──────────
  void _show(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));
}
