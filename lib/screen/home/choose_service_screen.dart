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
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.push(const RateOfServiceScreen());
          },
          icon: Image.asset("assets/img/menu.png", width: 20, height: 20),
        ),
        title: Row(
          children: [
            Image.asset(
              "assets/img/only_logo.png",
              height: 200,
              fit: BoxFit.fitHeight,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hi Choose",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Your",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      " Service Area",
                      style: TextStyle(
                        color: TColor.primaryText,
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
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                ),
                              ),
                              Text(
                                " Personal",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 20,
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
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                ),
                              ),
                              Text(
                                " Organisation",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 20,
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
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: TColor.secondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/img/search.png",
                              width: 15,
                              height: 15,
                            ),
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
                            title: "Late",
                            width: 100,
                            lineColor: Colors.white,
                            type: RoundButtonType.line,
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: RoundButton(
                            title: "Search Now",
                            onPressed: () {},
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
