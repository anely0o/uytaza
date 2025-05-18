import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/home/home_screen.dart';

class TemporaryPasswordChangeScreen extends StatefulWidget {
  const TemporaryPasswordChangeScreen({super.key});

  @override
  State<TemporaryPasswordChangeScreen> createState() =>
      _TemporaryPasswordChangeScreenState();
}

class _TemporaryPasswordChangeScreenState
    extends State<TemporaryPasswordChangeScreen> {
  TextEditingController txtTemporaryPassword = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();

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
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        RoundTextfield(
                          hintText: "Temporary Password",
                          obscureText: true,
                          controller: txtTemporaryPassword,
                        ),
                        const SizedBox(height: 25),
                        RoundTextfield(
                          hintText: "NewPassword",
                          obscureText: true,
                          right: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              "assets/img/show_pass.png",
                              width: 30,
                            ),
                          ),
                          controller: txtNewPassword,
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: RoundButton(
                            title: "CHANGE PASSWORD",
                            fontWeight: FontWeight.bold,
                            onPressed: () {
                              final tempPass = txtTemporaryPassword.text.trim();
                              final newPass = txtNewPassword.text.trim();

                              if (tempPass.isEmpty || newPass.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("please enter all"),
                                  ),
                                );
                                return;
                              }
                              // здесь будет реальный АПИ для смены пароля
                              // пока что просто показываем успех
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("пароль успешно изменен"),
                                ),
                              );
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  Navigator.pushReplacement(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
                      ],
                    ),
                  ),
                  Text(
                    "Forgot Password?",
                    style: TextStyle(color: TColor.primaryText, fontSize: 15),
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
