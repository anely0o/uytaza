import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/screen/home/subscription_cell.dart';
import 'package:uytaza/screen/order/client/order_build_page.dart';
import 'package:uytaza/screen/profile/about_us_screen.dart';
import 'package:uytaza/screen/login/api_service.dart';

// ▼ добавьте
import 'package:uytaza/screen/subscription/subscription_build_page.dart';
import 'package:uytaza/screen/subscription/subscriptions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ----------------  mock / banners / subs  ----------------
  final bannerArr = ["assets/img/banner1.png", "assets/img/banner2.png"];
  final subscriptionArr = [
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
  final PageController controller = PageController();
  int selectPage = 0;

  // ----------------  user profile ----------------
  bool _profileLoading = true;
  String _name = '';
  String? _address;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() =>
    selectPage = controller.page?.round() ?? 0));
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getWithToken(ApiRoutes.profile);
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body);

        final first = m['FirstName']?.toString() ?? '';
        final last  = m['LastName']?.toString() ?? '';
        _name = [first, last].where((e) => e.isNotEmpty).join(' ');
        if (_name.isEmpty) _name = 'User';

        _address   = m['Address']?.toString();
      }
    } catch (_) {/* ignore */}
    if (mounted) setState(() => _profileLoading = false);
  }

  // ----------------  UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F4F3),

      // Боковая панель (Drawer)
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: _profileLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: TColor.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : const AssetImage('assets/img/default_avatar.png') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _name.isNotEmpty ? _name : 'User',
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_address != null)
                    Text(
                      _address!,
                      style: TextStyle(
                        color: TColor.primaryText.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: const Text('New subscription'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionBuildPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('My subscriptions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                );
              },
            ),
          ],
        ),
      ),

      // ✅ Добавлен AppBar с кнопкой боковой панели
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Основной контент
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

  // ---------------- Top section with name / address ----------------
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
      child: _profileLoading
          ? const SizedBox(
          height: 50,
          child: Center(child: CircularProgressIndicator(color: Colors.white)))
          : Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: _avatarUrl != null
                ? NetworkImage(_avatarUrl!)
                : const AssetImage('assets/img/default_avatar.png')
            as ImageProvider,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _name.isNotEmpty ? _name : 'User',
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              if (_address != null)
                Row(
                  children: [
                    Image.asset("assets/img/location.png",
                        width: 15, height: 15),
                    const SizedBox(width: 5),
                    Text(
                      _address!,
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


  // ---------------- Banner carousel ----------------
  Widget _buildBannerSection() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller,
            itemCount: bannerArr.length,
            itemBuilder: (_, i) => Image.asset(
              bannerArr[i],
              width: context.width,
              height: context.width * 0.57,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (selectPage == 0)
          Positioned(
            bottom: 15,
            left: 15,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderBuildPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Get Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        // dots
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerArr.length,
                  (i) => Container(
                margin: const EdgeInsets.all(4),
                width: selectPage == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                  selectPage == i ? TColor.primary : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Subscriptions ----------------
  Widget _buildSubscriptionSection() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Subscription Offers!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Hygienic & single-use products | low-contact services',
              style: TextStyle(fontSize: 14, color: TColor.secondaryText),
            ),
          ),
          SizedBox(
            height: context.width * 0.7 + 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              itemBuilder: (_, i) => SubscriptionCell(
                obj: subscriptionArr[i],
                onPressed: () => debugPrint(subscriptionArr[i].toString()),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemCount: subscriptionArr.length,
            ),
          ),
        ],
      ),
    );
  }
}

