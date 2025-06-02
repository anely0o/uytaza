import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import '../main/main_tab_page.dart';
import '../../api/api_service.dart';

class TemporaryPasswordChangeScreen extends StatefulWidget {
  const TemporaryPasswordChangeScreen({super.key});

  @override
  State<TemporaryPasswordChangeScreen> createState() =>
      _TemporaryPasswordChangeScreenState();
}

class _TemporaryPasswordChangeScreenState
    extends State<TemporaryPasswordChangeScreen> {
  final txtTemporaryPassword = TextEditingController();
  final txtNewPassword = TextEditingController();

  void _changePassword() async {
    final tempPass = txtTemporaryPassword.text.trim();
    final newPass = txtNewPassword.text.trim();

    if (tempPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final token = await ApiService.getToken();

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/auth/set-initial-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'temporary_password': tempPass,
          'new_password': newPass,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully")),
        );
        context.push(MainTabPage());
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
          SizedBox(
            width: context.width,
            height: context.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  Image.asset(
                    "assets/img/logo.png",
                    width: context.width * 0.50,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 45,
                      horizontal: 25,
                    ),
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 45,
                      vertical: 25,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Change Temporary Password",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        RoundTextfield(
                          hintText: "Temporary Password",
                          obscureText: true,
                          controller: txtTemporaryPassword,
                        ),
                        const SizedBox(height: 15),
                        RoundTextfield(
                          hintText: "New Password",
                          obscureText: true,
                          controller: txtNewPassword,
                        ),
                        const SizedBox(height: 20),
                        RoundButton(
                          title: "CHANGE PASSWORD",
                          fontWeight: FontWeight.bold,
                          onPressed: _changePassword,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundButton(
                    title: "BACK TO SIGN IN",
                    width: context.width * 0.65,
                    type: RoundButtonType.line,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}