import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/link_button.dart';
import 'package:uytaza/common_widget/select_icon_title_button.dart';
import 'package:uytaza/screen/home/subscription_cell.dart';

import 'package:uytaza/screen/order/order_build_page.dart';
import 'package:uytaza/screen/profile/profile_screen.dart';
import 'package:uytaza/screen/main/main_tab_page.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List bannerArr = ["assets/img/banner1.png", "assets/img/banner2.png"];

  List subscriptionArr = [
    {
      "img": "assets/img/weekly.jpg",
      "title": "Weekly Cleaning Subscription",
      "subtitle": "Stay tidy every week!",
    },
    {
      "img": "assets/img/biweekly.jpg",
      "title": "Bi-Weekly Cleaning Subscription",
      "subtitle": "Just enough to stay fresh!",
    },
    {
      "img": "assets/img/monthly.jpg",
      "title": "Monthly Deep Cleaning",
      "subtitle": "Give your home a reset!",
    },
  ];

  PageController controller = PageController();
  int selectPage = 0;

  int selectCatIndex = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        selectPage = controller.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F4F3),
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: TColor.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    //avatar,name
                    GestureDetector(
                      onTap: () {
                        if (widget.onProfileTap != null) {
                          widget.onProfileTap!();
                        }
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(
                              "assets/img/avatar.jpg",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "John, Doe",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const SizedBox(height: 30),
                                  Image.asset(
                                    "assets/img/location.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Your address -",
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {},
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Tole Bi, 50",
                                          style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 13,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Image.asset(
                                          "assets/img/down.png",
                                          width: 15,
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: bannerArr.length,
                      itemBuilder: (context, index) {
                        var image = bannerArr[index];
                        return SizedBox(
                          width: context.width,
                          height: context.width * 0.57,
                          child: Image.asset(
                            image,
                            width: context.width,
                            height: context.width * 0.57,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                  if (selectPage == 0)
                    Positioned(
                      bottom: 15,
                      left: 15,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderBuildPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Get Plan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          bannerArr.map((image) {
                            var index = bannerArr.indexOf(image);
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                width: selectPage == index ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      selectPage == index
                                          ? TColor.primary
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),

              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.symmetric(vertical: 15),
                width: double.maxFinite,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Subscription Offers!",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),
                              Text(
                                "Hygenic & sungle-use products | low-contact services",
                                style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: context.width * 0.7 + 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 15,
                        ),

                        itemBuilder: (context, index) {
                          var obj = subscriptionArr[index];
                          return SubscriptionCell(
                            obj: obj,
                            onPressed: () {
                              debugPrint(obj.toString());
                            },
                          );
                        },
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 15),
                        itemCount: subscriptionArr.length,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
