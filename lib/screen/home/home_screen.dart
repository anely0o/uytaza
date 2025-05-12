import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/link_button.dart';
import 'package:uytaza/common_widget/select_icon_title_button.dart';
import 'package:uytaza/screen/home/subscription_cell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    {
      "img": "assets/img/daily.jpg",
      "title": "Daily Light Cleaning (Premium)",
      "subtitle": "Always spotless, always ready.",
    },
    {
      "img": "assets/img/custom.jpg",
      "title": "Custom Cleaning Plan",
      "subtitle": "Your cleaning, your rules.",
    },
    {
      "img": "assets/img/office.jpg",
      "title": "Office Cleaning Subscription",
      "subtitle": "Keep your team healthy & happy.",
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    style: TextStyle(color: TColor.primaryText, fontSize: 17),
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
                      hintText: "Search for service ...",
                      hintStyle: TextStyle(
                        color: TColor.placeholder,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: [
                    LinkButton(title: "One-time", onPressed: () {}),
                    LinkButton(title: "Weekly", onPressed: () {}),
                    LinkButton(title: "Express", onPressed: () {}),
                    LinkButton(title: "Deep Clean", onPressed: () {}),
                    const SizedBox(width: 8),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 15, height: 30),
                    Image.asset(
                      "assets/img/location.png",
                      width: 15,
                      height: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Your address -",
                      style: TextStyle(color: TColor.primaryText, fontSize: 13),
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
                              decoration: TextDecoration.underline,
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
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 15,
                    ),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SelectIconTitleButton(
                            title: "Carpet Cleaning",
                            icon: "assets/img/carpet.png",
                            isSelect: selectCatIndex == 0,
                            onPressed: () {
                              setState(() {
                                selectCatIndex = 0;
                              });
                            },
                          ),

                          SelectIconTitleButton(
                            title: "Laundry & Hanging",
                            icon: "assets/img/laundry.png",
                            isSelect: selectCatIndex == 1,
                            onPressed: () {
                              setState(() {
                                selectCatIndex = 1;
                              });
                            },
                          ),

                          SelectIconTitleButton(
                            title: " Window Cleaning",
                            icon: "assets/img/window-cleaning.png",
                            isSelect: selectCatIndex == 2,
                            onPressed: () {
                              setState(() {
                                selectCatIndex = 2;
                              });
                            },
                          ),

                          SelectIconTitleButton(
                            title: "Disinfection Service",
                            icon: "assets/img/hand-sanitizer.png",
                            isSelect: selectCatIndex == 3,
                            onPressed: () {
                              setState(() {
                                selectCatIndex = 3;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

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
        ],
      ),
    );
  }
}
