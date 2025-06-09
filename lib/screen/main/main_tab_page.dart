import 'dart:async';
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
import 'package:uytaza/screen/history/client_history_screen.dart';
import 'package:uytaza/screen/history/cleaner_history_screen.dart';
import '../home/home_screen.dart';
import '../order/cleaner/cleaner_orders_screen.dart';
import '../subscription/subscriptions_screen.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  late Timer _refreshTimer;
  int _selectedIndex = 0;
  bool _argsHandled = false;

  UserRole? _userRole;
  bool _loadingRole = true;
  String? _error;
  int _unread = 0;

  // Данные профиля
  String _firstName = '';
  String _lastName = '';
  String _address = '';
  String _email = '';
  bool _loadingProfile = true;

  // Данные геймификации и рейтинга
  double _rating = 0.0;
  int _currentLevel = 0;
  int _xpTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadUnread();

    // Обновляем данные каждые 2 минуты
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _loadUnread();
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
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
        // После загрузки роли загружаем профиль
        _loadProfile();
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
        final decoded = jsonDecode(res.body) as List<dynamic>;
        final unreadCount = decoded
            .whereType<Map<String, dynamic>>()
            .where((n) => (n['is_read'] as bool? ?? false) == false)
            .length;
        if (mounted) setState(() => _unread = unreadCount);
      }
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    if (_userRole == null) return;

    setState(() => _loadingProfile = true);

    try {
      // Загружаем основные данные профиля
      final profileRes = await ApiService.getWithToken(ApiRoutes.profile);
      if (profileRes.statusCode == 200) {
        final profileData = jsonDecode(profileRes.body) as Map<String, dynamic>;

        // Обрабатываем разные варианты ключей (с заглавной буквы и без)
        _firstName = (profileData['FirstName'] ?? profileData['first_name'] ?? '').toString();
        _lastName = (profileData['LastName'] ?? profileData['last_name'] ?? '').toString();
        _address = (profileData['Address'] ?? profileData['address'] ?? '').toString();
        _email = (profileData['Email'] ?? profileData['email'] ?? '').toString();

        // Для клинера загружаем рейтинг из профиля
        if (_userRole == UserRole.cleaner) {
          _rating = (profileData['average_rating'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // Загружаем данные геймификации
      final gamificationRes = await ApiService.getWithToken(ApiRoutes.gamificationStatus);
      if (gamificationRes.statusCode == 200) {
        final gamData = jsonDecode(gamificationRes.body) as Map<String, dynamic>;
        _currentLevel = (gamData['current_level'] as num?)?.toInt() ?? 0;
        _xpTotal = (gamData['xp_total'] as num?)?.toInt() ?? 0;
      }

    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  String get _fullName {
    final name = '$_firstName $_lastName'.trim();
    return name.isNotEmpty ? name : 'User';
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

    final icons = <String>[
      'assets/img/home_icon.png',
      'assets/img/calendar_icon.png',
      'assets/img/profile_icon.png',
    ];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _loadingProfile
                      ? const Center(child: CircularProgressIndicator())
                      : (_userRole == UserRole.client
                      ? _buildClientHeader()
                      : _buildCleanerHeader()),
                ),
              ),
              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: const Text('History'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _userRole == UserRole.cleaner
                              ? const CleanerHistoryScreen()
                              : const ClientHistoryScreen(),
                        ),
                      );
                    },
                  ),
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
                ]),
              ),
            ],
          ),
        ),
      ),
      appBar: (_selectedIndex == 2)
          ? null
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: _buildAppBarTitle(),
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
            label: '',
          );
        }),
      ),
    );
  }

  /// Заголовок AppBar в зависимости от роли пользователя
  Widget _buildAppBarTitle() {
    if (_loadingProfile) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_userRole == UserRole.cleaner) {
      // Для клинера показываем имя и фамилию
      return Text(
        _fullName,
        style: TextStyle(
          color: TColor.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      // Для клиента показываем адрес с иконкой
      if (_address.isNotEmpty) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              color: TColor.primary,
              size: 18,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _address,
                style: TextStyle(
                  color: TColor.textPrimary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      } else {
        return Text(
          _fullName,
          style: TextStyle(
            color: TColor.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        );
      }
    }
  }

  /// Заголовок боковой панели для клиента
  Widget _buildClientHeader() {
    final xpForCurrentLevel = _xpTotal % 100;
    final progress = xpForCurrentLevel / 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Имя и фамилия
        Text(
          _fullName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TColor.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Адрес с иконкой
        if (_address.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: TColor.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _address,
                  style: TextStyle(
                    fontSize: 14,
                    color: TColor.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Уровень и XP
        Row(
          children: [
            Icon(Icons.star, size: 16, color: TColor.primary),
            const SizedBox(width: 4),
            Text(
              'Level $_currentLevel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColor.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                'XP: $xpForCurrentLevel/100',
                style: TextStyle(
                  fontSize: 12,
                  color: TColor.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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

  /// Заголовок боковой панели для клинера
  Widget _buildCleanerHeader() {
    final xpForCurrentLevel = _xpTotal % 100;
    final progress = xpForCurrentLevel / 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Имя и фамилия
        Text(
          _fullName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TColor.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Рейтинг со звездами - сделаем более компактным
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '${_rating.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColor.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Уровень и XP - более компактно
        Row(
          children: [
            Icon(Icons.military_tech, size: 16, color: TColor.primary),
            const SizedBox(width: 4),
            Text(
              'Level $_currentLevel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColor.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                'XP: $xpForCurrentLevel/100',
                style: TextStyle(
                  fontSize: 12,
                  color: TColor.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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
}
