import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/profile/rate_of_service_screen.dart';

class ChooseServiceScreen extends StatefulWidget {
  const ChooseServiceScreen({super.key});

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  bool isHome = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white, // Neutral navbar
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.push(const RateOfServiceScreen());
          },
          icon: Icon(Icons.menu, color: TColor.primary),
        ),
        title: Image.asset(
          "assets/img/only_logo.png",
          height: 40,
          fit: BoxFit.fitHeight,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, Choose",
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Your",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " Service Area",
                      style: TextStyle(
                        color: TColor.textPrimary,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isHome = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: TColor.softShadow,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    !isHome
                                        ? "assets/img/select_radio.png"
                                        : "assets/img/unselect_radio.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 25,
                                ),
                                child: Image.asset(
                                  "assets/img/1.png",
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              Text(
                                "Home",
                                style: TextStyle(
                                  color: TColor.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Personal",
                                style: TextStyle(
                                  color: TColor.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isHome = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: TColor.softShadow,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    isHome
                                        ? "assets/img/select_radio.png"
                                        : "assets/img/unselect_radio.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 25,
                                ),
                                child: Image.asset(
                                  "assets/img/2.png",
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              Text(
                                "Business",
                                style: TextStyle(
                                  color: TColor.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Organisation",
                                style: TextStyle(
                                  color: TColor.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: TColor.card,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: TColor.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: TColor.textPrimary,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Icon(Icons.search, color: TColor.primary),
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Enter Your Address ...",
                          hintStyle: TextStyle(
                            color: TColor.placeholder,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: RoundButton(
                            title: "Later",
                            width: 100,
                            lineColor: TColor.primary,
                            type: RoundButtonType.line,
                            onPressed: () {},
                            textColor: TColor.primary,
                          ),
                        ),
                         SizedBox(width: 8),
                        Expanded(
                          child: RoundButton(
                            title: "Search Now",
                            onPressed: () {},
                            backgroundColor: TColor.primary,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
