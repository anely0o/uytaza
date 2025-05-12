import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'package:uytaza/screen/login/temporary_password_change_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignUpScreen> {
  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
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
                      vertical: 15,
                      horizontal: 15,
                    ),
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
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
                          "SignUp",
                          style: TextStyle(
                            color: TColor.title,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                        NewRoundTextfield(
                          hintText: "Address",
                          keyboardType: TextInputType.streetAddress,
                          controller: txtAddress,
                        ),
                        const SizedBox(height: 10),
                        NewRoundTextfield(
                          hintText: "Mobile Number",
                          keyboardType: TextInputType.phone,
                          controller: txtMobile,
                        ),
                        const SizedBox(height: 10),
                        NewRoundTextfield(
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
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: RoundButton(
                            title: "SIGN UP",
                            fontWeight: FontWeight.bold,
                            onPressed: () {
                              context.push(
                                const TemporaryPasswordChangeScreen(),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Or Sign Up with",
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
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: TColor.primaryText, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  RoundButton(
                    title: "SIGN IN",
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
