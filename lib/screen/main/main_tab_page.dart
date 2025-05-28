import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/profile/user_config.dart';
import 'package:uytaza/screen/home/home_screen.dart';
import 'package:uytaza/screen/message/chat_message_screen.dart';
import 'package:uytaza/screen/order/client/orders_screen.dart';
import 'package:uytaza/screen/order/cleaner/cleaner_orders_screen.dart';
import 'package:uytaza/screen/profile/client/client_profile_screen.dart';
import 'package:uytaza/screen/profile/cleaner/cleaner_profile_screen.dart';
import 'package:uytaza/screen/notification/notifications_screen.dart';
import 'package:uytaza/screen/login/api_service.dart';
import 'package:uytaza/api/api_routes.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});
  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _selectedIndex = 0;
  bool _argsHandled  = false;

  UserRole? _userRole;
  bool _loadingRole  = true;
  String? _error;

  int _unread = 0;         // ← badge counter

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadUnread();          // ← один раз при старте
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsHandled) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int && arg >= 0 && arg <= 3) _selectedIndex = arg;
    _argsHandled = true;
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await ApiService.getUserRole();
      if (mounted) setState(() {
        _userRole    = role;
        _loadingRole = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error       = '$e';
        _loadingRole = false;
      });
    }
  }

  Future<void> _loadUnread() async {
    try {
      final res = await ApiService.getWithToken(ApiRoutes.notificationsCount);
      if (res.statusCode == 200) {
        final n = jsonDecode(res.body)['unread'] as int? ?? 0;
        if (mounted) setState(() => _unread = n);
      }
    } catch (_) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _userRole == null) {
      return Scaffold(body: Center(child: Text(_error ?? 'Role error')));
    }

    final ordersPage  = _userRole == UserRole.cleaner
        ? const CleanerOrdersScreen()
        : const OrdersScreen();

    final profilePage = _userRole == UserRole.cleaner
        ? const CleanerProfileScreen()
        : const ClientProfileScreen();

    final pages  = [
      const HomeScreen(),
      const ChatMessageScreen(),
      ordersPage,
      profilePage,
    ];

    final labels = ['Home', 'Messages', 'Orders', 'Profile'];
    final icons  = [
      'assets/img/home_icon.png',
      'assets/img/message_icon.png',
      'assets/img/calendar_icon.png',
      'assets/img/profile_icon.png',
    ];

    return Scaffold(
      //-------------------------------------------------------
      // AppBar только если НЕ Profile
      //-------------------------------------------------------
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Text(labels[_selectedIndex],
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsScreen()),
              );
              // после возврата обновим счётчик
              _loadUnread();
            },
            icon: badges.Badge(
              showBadge: _unread > 0,
              badgeContent: Text('$_unread',
                  style:
                  const TextStyle(fontSize: 10, color: Colors.white)),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
      ),

      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: TColor.primary,
        selectedItemColor: TColor.primaryText,
        unselectedItemColor: TColor.secondaryText,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: List.generate(icons.length, (i) {
          final sel = _selectedIndex == i;
          return BottomNavigationBarItem(
            icon: Image.asset(icons[i],
                width: 24,
                height: 24,
                color: sel ? TColor.primaryText : TColor.secondaryText),
            label: labels[i],
          );
        }),
      ),
    );
  }
}


