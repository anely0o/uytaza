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
import 'package:uytaza/screen/history/history_screen.dart';
import '../home/home_screen.dart';
import '../order/cleaner/cleaner_orders_screen.dart';
import '../subscription/subscriptions_screen.dart';

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

  // Обычные профильные поля
  String? _firstName;
  String? _lastName;
  String? _address;       // <-- адрес пользователя
  bool _loadingProfile = true;

  // Только для клинера: рейтинг
  double? _rating;

  // Gamification fields
  int _currentLevel = 0;
  int _xpTotal      = 0;

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
      final res = await ApiService.getWithToken(ApiRoutes.notificationsAll);
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        final unreadCount = decoded
            .whereType<Map<String, dynamic>>()
            .where((n) => (n['is_read'] as bool? ?? false) == false)
            .length;
        if (mounted) setState(() => _unread = unreadCount);
      }
    } catch (_) {
      // Игнорируем сетевые ошибки
    }
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getWithToken(ApiRoutes.profile);
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        _firstName = (m['FirstName'] ?? m['first_name'] ?? '').toString();
        _lastName  = (m['LastName']  ?? m['last_name']  ?? '').toString();

        // Добавляем адрес в профиль
        _address = (m['Address'] ?? m['address'] ?? '').toString();

        // Если роль – клинер, получаем рейтинг
        if (_userRole == UserRole.cleaner) {
          final cleanerId = (m['id'] ?? '').toString();
          if (cleanerId.isNotEmpty) {
            final rateRes = await ApiService.getWithToken(
              '${ApiRoutes.ratingCleaner}$cleanerId',
            );
            if (rateRes.statusCode == 200) {
              final rd = jsonDecode(rateRes.body) as Map<String, dynamic>;
              _rating = (rd['rating'] ?? 0).toDouble();
            }
          }
        }

        // ── Запрашиваем gamification status для обоих (уровень + XP)
        try {
          final gamRes =
          await ApiService.getWithToken(ApiRoutes.gamificationStatus);
          if (gamRes.statusCode == 200) {
            final gd = jsonDecode(gamRes.body) as Map<String, dynamic>;
            _currentLevel = (gd['current_level'] as num).toInt();
            _xpTotal      = (gd['xp_total'] as num).toInt();
          }
        } catch (_) {
          // Игнорируем ошибки запроса gamification
        }
      }
    } catch (_) {
      // Игнорируем ошибки
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

    // Выбираем страницы в зависимости от роли
    final ordersPage = (_userRole == UserRole.cleaner)
        ? const CleanerOrdersScreen()
        : const OrdersScreen();
    final profilePage = (_userRole == UserRole.cleaner)
        ? const CleanerProfileScreen()
        : const ClientProfileScreen();

    // Home одинаков для обеих ролей
    final pages = [
      const HomeScreen(),
      ordersPage,
      profilePage,
    ];

    // Иконки нижней навигации
    final icons = <String>[
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
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: _loadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : (_userRole == UserRole.client
                  ? _buildClientHeader()
                  : _buildCleanerHeader()),
            ),
            // Общий пункт: История
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
            // Только для клиента: Мои подписки
            if (_userRole == UserRole.client) ...[
              ListTile(
                leading: const Icon(Icons.repeat, color: Colors.grey),
                title: const Text('My Subscriptions'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubscriptionsScreen()),
                  );
                },
              ),
            ],
            // Общий пункт: Служба поддержки
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.grey),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SupportHomeScreen()),
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
        title: const SizedBox.shrink(),
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primary),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsScreen()),
              );
              _loadUnread();
            },
            icon: badges.Badge(
              showBadge: _unread > 0,
              badgeContent: const SizedBox.shrink(),
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.circle,
                badgeColor: Colors.yellow,
                padding: const EdgeInsets.all(6),
                elevation: 0,
              ),
              position:
              badges.BadgePosition.topEnd(top: -4, end: -4),
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
        selectedItemColor: Colors.black,
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
                color: TColor.primary.withOpacity(0.2),
              )
                  : null,
              child: Image.asset(
                icons[i],
                width: 24,
                height: 24,
                color: isSelected ? Colors.black : TColor.textSecondary,
              ),
            ),
            label: i == 0
                ? (_userRole == UserRole.cleaner ? 'Home' : '')
                : i == 1
                ? (_userRole == UserRole.cleaner ? 'Orders' : '')
                : (_userRole == UserRole.cleaner ? 'Profile' : ''),
          );
        }),
      ),
    );
  }

  /// Сборка заголовка для клиента:
  Widget _buildClientHeader() {
    // Вычисляем прогресс XP (предполагаем 100 XP на уровень)
    final xpForCurrentLevel = _xpTotal % 100;
    final progress = xpForCurrentLevel / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Имя
        Text(
          '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TColor.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Адрес под именем
        if (_address != null && _address!.isNotEmpty)
          Text(
            _address!,
            style: TextStyle(fontSize: 14, color: TColor.textSecondary),
          ),
        const SizedBox(height: 12),
        // Шкала геймофикации (LinearProgressIndicator)
        Text(
          'Level $_currentLevel   •   XP $xpForCurrentLevel/100',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TColor.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: TColor.divider,
            color: TColor.primary,
          ),
        ),
      ],
    );
  }

  /// Сборка заголовка для клинера:
  Widget _buildCleanerHeader() {
    // Вычисляем прогресс XP (предполагаем 100 XP на уровень)
    final xpForCurrentLevel = _xpTotal % 100;
    final progress = xpForCurrentLevel / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Имя
        Text(
          '${_firstName ?? ''} ${_lastName ?? ''}'.trim(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TColor.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Рейтинг звёздами
        Row(
          children: [
            ..._buildStarIcons(_rating ?? 0),
            const SizedBox(width: 8),
            Text(
              '(${(_rating ?? 0).toStringAsFixed(1)})',
              style: TextStyle(
                fontSize: 16,
                color: TColor.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Шкала геймофикации (LinearProgressIndicator)
        Text(
          'Level $_currentLevel   •   XP $xpForCurrentLevel/100',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TColor.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: TColor.divider,
            color: TColor.primary,
          ),
        ),
      ],
    );
  }

  /// Отрисовка звёзд по рейтингу
  List<Widget> _buildStarIcons(double rating) {
    const totalStars = 5;
    int full = rating.floor();
    bool hasHalf = (rating - full) >= 0.5;
    List<Widget> stars = [];
    for (int i = 0; i < full; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 20));
    }
    if (hasHalf) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 20));
    }
    while (stars.length < totalStars) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 20));
    }
    return stars;
  }
}
