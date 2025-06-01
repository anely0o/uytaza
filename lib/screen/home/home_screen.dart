import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/select_icon_title_button.dart';
import 'package:uytaza/screen/home/subscription_cell.dart';
import 'package:uytaza/screen/order/client/order_build_page.dart';
import 'package:uytaza/screen/profile/about_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> bannerArr = ["assets/img/banner1.png", "assets/img/banner2.png"];

  List<Map<String, String>> subscriptionArr = [
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
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: TColor.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage("assets/img/avatar.jpg"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "John Doe",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tole Bi, 50",
                    style: TextStyle(
                      color: TColor.primaryText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context); // Закрыть Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Image.asset(
          "assets/img/only_logo.png",
          height: 200,
          fit: BoxFit.fitHeight,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopSection(),
              const SizedBox(height: 20),
              _buildBannerSection(),
              _buildSubscriptionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: TColor.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/img/avatar.jpg"),
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
                  Image.asset("assets/img/location.png", width: 15, height: 15),
                  const SizedBox(width: 5),
                  Text(
                    "Tole Bi, 50",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller,
            itemCount: bannerArr.length,
            itemBuilder: (context, index) {
              return Image.asset(
                bannerArr[index],
                width: context.width,
                height: context.width * 0.57,
                fit: BoxFit.cover,
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
                    builder: (context) => const OrderBuildPage(),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            selectPage == index ? TColor.primary : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Subscription Offers!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Hygienic & single-use products | low-contact services",
              style: TextStyle(fontSize: 14, color: TColor.secondaryText),
            ),
          ),
          SizedBox(
            height: context.width * 0.7 + 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              itemBuilder: (context, index) {
                var obj = subscriptionArr[index];
                return SubscriptionCell(
                  obj: obj,
                  onPressed: () {
                    debugPrint(obj.toString());
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemCount: subscriptionArr.length,
            ),
          ),
        ],
      ),
    );
  }
}
