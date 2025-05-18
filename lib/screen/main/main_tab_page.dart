import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/message/message_screen.dart';
import 'package:uytaza/screen/order/orders_screen.dart';
import 'package:uytaza/screen/profile/profile_screen.dart';

class MainTabPage extends StatefulWidget {
  final int initialIndex;

  const MainTabPage({super.key, this.initialIndex = 0});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  late int selectedIndex;

  final List<Widget> pages = const [
    HomeScreen(),
    MessageScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  final List<String> icons = [
    "assets/img/home_icon.png",
    "assets/img/message_icon.png",
    "assets/img/calendar_icon.png",
    "assets/img/profile_icon.png",
  ];

  final List<String> labels = ["Home", "Messages", "Orders", "Profile"];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: TColor.primary,
        selectedItemColor: TColor.primaryText,
        unselectedItemColor: TColor.secondaryText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: List.generate(icons.length, (index) {
          bool isSelected = selectedIndex == index;
          return BottomNavigationBarItem(
            icon: Image.asset(
              icons[index],
              width: 24,
              height: 24,
              color: isSelected ? TColor.primaryText : TColor.secondaryText,
            ),
            label: labels[index],
          );
        }),
      ),
    );
  }
}
