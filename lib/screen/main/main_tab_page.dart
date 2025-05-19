import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/message/chat_message_screen.dart';
import 'package:uytaza/screen/message/message_screen.dart';
import 'package:uytaza/screen/models/user_model.dart';
import 'package:uytaza/screen/order/orders_screen.dart';
import 'package:uytaza/screen/profile/profile_screen.dart';

class MainTabPage extends StatefulWidget {
  final int initialIndex;
  final UserModel user;

  const MainTabPage({super.key, this.initialIndex = 0, required this.user});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  late int _selectedIndex;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _user = widget.user;
  }

  void _updateUser(UserModel newUser) {
    setState(() {
      _user = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        user: _user,
        onUpdateUser: _updateUser,
        onProfileTap: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
      ),
      ChatMessageScreen(),
      OrdersScreen(user: widget.user),
      ProfileScreen(user: _user, onUpdateUser: _updateUser),
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
