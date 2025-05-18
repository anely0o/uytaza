import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController txtEmail = TextEditingController();

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
                      vertical: 25,
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
                          "Forgot Password?",
                          style: TextStyle(
                            color: TColor.title,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        RoundTextfield(
                          hintText: "Enter your email",
                          keyboardType: TextInputType.emailAddress,
                          controller: txtEmail,
                        ),
                        const SizedBox(height: 25),
                        RoundButton(
                          title: "SEND TEMPORARY PASSWORD",
                          fontWeight: FontWeight.bold,
                          onPressed: () {
                            final email = txtEmail.text.trim();
                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("please enter your email"),
                                ),
                              );
                              return;
                            }

                            // здесь должен быть API вызов
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Temporary password sent to $email",
                                ),
                              ),
                            );
                            context.pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
