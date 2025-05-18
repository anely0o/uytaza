import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/login/forgot_password_screen.dart';
import 'package:uytaza/screen/login/sign_up_screen.dart';
import 'package:uytaza/screen/main/main_tab_page.dart';

import 'package:uytaza/screen/login/temporary_password_change_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

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
                          "Sign In",
                          style: TextStyle(
                            color: TColor.title,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        RoundTextfield(
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          controller: txtEmail,
                        ),
                        const SizedBox(height: 25),
                        RoundTextfield(
                          hintText: "Password",
                          obscureText: true,
                          right: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              "assets/img/show_pass.png",
                              width: 30,
                            ),
                          ),
                          controller: txtPassword,
                        ),
                        const SizedBox(height: 15),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: RoundButton(
                            title: "SIGN IN",
                            fontWeight: FontWeight.bold,
                            onPressed: () async {
                              final email = txtEmail.text.trim();
                              final password = txtPassword.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("enter email and password"),
                                  ),
                                );
                                return;
                              }
                              //временно имитируем поведение сервера
                              final isTemporaryPassword =
                                  password ==
                                  '123456'; //позже заменим на реальный запрос

                              if (isTemporaryPassword) {
                                context.push(
                                  const TemporaryPasswordChangeScreen(),
                                );
                              } else {
                                context.push(const MainTabPage());
                              }
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                context.push(const ForgotPasswordScreen());
                              },
                              child: Text(
                                "Forgot Password |",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Or Sign In with",
                            style: TextStyle(
                              color: TColor.placeholder,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Image.asset(
                                "assets/img/google.png",
                                width: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  RoundButton(
                    title: "SIGNUP",
                    width: context.width * 0.65,
                    type: RoundButtonType.line,
                    onPressed: () {
                      context.push(SignUpScreen());
                    },
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
