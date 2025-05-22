import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/message/chat_message_screen.dart';
import 'package:uytaza/screen/profile/profile_router_screen.dart';
import 'package:uytaza/screen/order/client/orders_screen.dart';
import 'package:uytaza/screen/order/cleaner/cleaner_orders_screen.dart';
import 'package:uytaza/screen/profile/client/client_profile_screen.dart';
import 'package:uytaza/screen/profile/cleaner/cleaner_profile_screen.dart';

class MainTabPage extends StatefulWidget {
  final int initialIndex;

  const MainTabPage({super.key, this.initialIndex = 0});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  late int _selectedIndex;

  // Мок роли — поменяй здесь на 'cleaner' или 'client', чтобы проверить
  String userRole = 'client'; // например 'client' или 'cleaner'

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Выбираем экран заказов в зависимости от роли пользователя
    final Widget ordersPage =
        userRole == 'cleaner'
            ? const CleanerOrdersScreen()
            : const OrdersScreen();

    final Widget profilePage =
        userRole == 'cleaner'
            ? const CleanerProfileScreen()
            : const ClientProfileScreen();

    final List<Widget> pages = [
      const HomeScreen(),
      const ChatMessageScreen(),
      ordersPage, // динамический экран заказов
      profilePage, // **здесь используй profilePage, а не ProfileRouterScreen()**
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
