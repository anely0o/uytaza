// lib/screen/main/main_tab_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/profile/user_config.dart' show UserRole;
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/screen/order/client/orders_screen.dart';
import 'package:uytaza/screen/profile/cleaner/cleaner_profile_screen.dart';
import 'package:uytaza/screen/profile/client/client_profile_screen.dart';
import 'package:uytaza/screen/notification/notifications_screen.dart';
import 'package:uytaza/screen/message/support_home_screen.dart';
import 'package:uytaza/screen/subscription/subscriptions_screen.dart';
import 'package:uytaza/screen/profile/about_us_screen.dart';
import 'package:uytaza/screen/history/history_screen.dart';

import '../home/home_screen.dart';
import '../order/cleaner/cleaner_orders_screen.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});
  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _selectedIndex = 0;
  bool _argsHandled = false;
  UserRole? _userRole;
  bool _loadingRole = true;
  String? _error;
  int _unread = 0;

  // Профиль клиента
  String? _address;
  String? _firstName;
  String? _lastName;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadUnread();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsHandled) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int && arg >= 0 && arg <= 2) {
      _selectedIndex = arg;
    }
    _argsHandled = true;
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await ApiService.getUserRole();
      if (mounted) {
        setState(() {
          _userRole = role;
          _loadingRole = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loadingRole = false;
        });
      }
    }
  }

  Future<void> _loadUnread() async {
    try {
      // Вместо /notificationsCount возьмём полный список
      final res = await ApiService.getWithToken('/api/notifications');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        // Оставляем только те элементы, у которых "read" == false
        final unreadCount = decoded
            .whereType<Map<String, dynamic>>()
            .where((n) => (n['is_read'] as bool? ?? false) == false)
            .length;
        if (mounted) setState(() => _unread = unreadCount);
      }
    } catch (_) {
      // игнорируем ошибку сети
    }
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getWithToken(ApiRoutes.profile);
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body);
        _address = m['Address']?.toString();
        _firstName = m['FirstName']?.toString() ?? m['first_name']?.toString();
        _lastName = m['LastName']?.toString() ?? m['last_name']?.toString();
      }
    } catch (_) {
      // игнорируем
    }
    if (mounted) setState(() => _loadingProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _userRole == null) {
      return Scaffold(
        body: Center(child: Text(_error ?? 'Role error')),
      );
    }

    final ordersPage = (_userRole == UserRole.cleaner)
        ? const CleanerOrdersScreen()
        : const OrdersScreen();
    final profilePage = (_userRole == UserRole.cleaner)
        ? const CleanerProfileScreen()
        : const ClientProfileScreen();

    final pages = [
      const HomeScreen(),
      ordersPage,
      profilePage,
    ];
    final icons = [
      'assets/img/home_icon.png',
      'assets/img/calendar_icon.png',
      'assets/img/profile_icon.png',
    ];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          children: [
            // DrawerHeader с именем и адресом клиента
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: _userRole == UserRole.client
                  ? (_loadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _address ?? 'No address',
                    style: TextStyle(
                      fontSize: 16,
                      color: TColor.textSecondary,
                    ),
                  ),
                ],
              ))
                  : const SizedBox.shrink(),
            ),
            // История
            ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            // My Subscriptions
            ListTile(
              leading: const Icon(Icons.repeat, color: Colors.grey),
              title: const Text('My Subscriptions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                );
              },
            ),
            // About Us
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                );
              },
            ),
            // Support
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.grey),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportHomeScreen()),
                );
              },
            ),
          ],
        ),
      ),

      appBar: (_selectedIndex == 2)
          ? null
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        // Если клиент и вкладка Home или Orders, показываем адрес
        title: _userRole == UserRole.client &&
            (_selectedIndex == 0 || _selectedIndex == 1)
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on,
                color: TColor.primary, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _address ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: TColor.textPrimary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
            : const SizedBox.shrink(),
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primary),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
              _loadUnread();
            },
            icon: badges.Badge(
              showBadge: _unread > 0,
              badgeContent: const SizedBox.shrink(), // пустое содержимое
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.circle,
                badgeColor: Colors.yellow,
                padding: const EdgeInsets.all(6),    // тут определяем «радиус» точки
                elevation: 0,
              ),
              position: badges.BadgePosition.topEnd(top: -4, end: -4),
              child: Icon(
                Icons.notifications_none_rounded,
                color: TColor.primary,
              ),
            ),
          ),
        ],
      ),

      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black, // иконка выбранной вкладки – чёрная
        unselectedItemColor: TColor.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: List.generate(icons.length, (i) {
          final isSelected = (_selectedIndex == i);
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: isSelected
                  ? BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow, // выделение жёлтым
              )
                  : null,
              child: Image.asset(
                icons[i],
                width: 24,
                height: 24,
                color: isSelected ? Colors.black : TColor.textSecondary,
              ),
            ),
            label: '',
          );
        }),
      ),
    );
  }
}
