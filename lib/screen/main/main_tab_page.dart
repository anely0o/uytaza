import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/message/chat_message_screen.dart';

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
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const ChatMessageScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    final List<String> icons = [
      "assets/img/home_icon.png",
      "assets/img/message_icon.png",
      "assets/img/calendar_icon.png",
      "assets/img/profile_icon.png",
    ];

    final List<String> labels = ["Home", "Messages", "Orders", "Profile"];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: TColor.primary,
        selectedItemColor: TColor.primaryText,
        unselectedItemColor: TColor.secondaryText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: List.generate(icons.length, (index) {
          bool isSelected = _selectedIndex == index;
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
