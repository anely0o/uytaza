// lib/screen/profile/cleaner/cleaner_profile_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/profile/client/settings_screen.dart';

import '../../order/cleaner/cleaner_orders_screen.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({super.key});

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  final TextEditingController _firstNameCtl = TextEditingController();
  final TextEditingController _lastNameCtl = TextEditingController();
  double _rating = 0.0;
  bool _loading = true;
  String? _error;

  // Список отзывов
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadCleanerInfo();
  }

  Future<void> _loadCleanerInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Получаем профиль (имя, фамилию) текущего клинера
      final profileRes = await ApiService.getWithToken('/api/auth/profile');
      if (profileRes.statusCode != 200) {
        throw 'Ошибка ${profileRes.statusCode} при загрузке профиля';
      }
      final profileData = jsonDecode(profileRes.body) as Map<String, dynamic>;
      _firstNameCtl.text =
          profileData['FirstName'] ?? profileData['first_name'] ?? '';
      _lastNameCtl.text =
          profileData['LastName'] ?? profileData['last_name'] ?? '';

      // 2) Получаем рейтинг клинера
      // Предположим, что есть endpoint GET /api/rating/cleaner/:id
      final cleanerId = profileData['id']?.toString() ?? '';
      if (cleanerId.isNotEmpty) {
        final ratingRes =
        await ApiService.getWithToken('/api/rating/cleaner/$cleanerId');
        if (ratingRes.statusCode == 200) {
          final rd = jsonDecode(ratingRes.body);
          _rating = double.tryParse(rd['rating'].toString()) ?? 0.0;
        }
      }

      // 3) Получаем список отзывов для данного клинера
      // Предполагается, что есть endpoint /api/reviews/cleaner/:cleanerId
      final reviewsRes =
      await ApiService.getWithToken('/api/reviews/cleaner/$cleanerId');
      if (reviewsRes.statusCode == 200) {
        final list = jsonDecode(reviewsRes.body) as List<dynamic>;
        _reviews = list.whereType<Map<String, dynamic>>().toList();
      } else {
        // Если 404 или что-то – просто оставляем пустой список
        _reviews = [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TColor.primary,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30)),
                boxShadow: TColor.softShadow,
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 30),
                children: [
                  const SizedBox(height: 8),
                  _buildRatingTile(),
                  const SizedBox(height: 16),
                  _buildReviewsSection(),
                  const SizedBox(height: 30),
                  _buildNavigationTile(), // боковое меню (история заказов, поддержка, о нас)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: SizedBox(), // просто пустое место под заголовок
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            "${_firstNameCtl.text} ${_lastNameCtl.text}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Cleaner",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRatingTile() {
    return ListTile(
      leading: Icon(Icons.star, color: TColor.primary),
      title: Text(
        "Rating: ${_rating.toStringAsFixed(1)}",
        style: TextStyle(
          color: TColor.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: List.generate(5, (index) {
          return Icon(
            index < _rating.round() ? Icons.star : Icons.star_border,
            color: TColor.accent,
            size: 20,
          );
        }),
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (_reviews.isEmpty) {
      return Center(
        child: Text(
          'У вас пока нет отзывов',
          style: TextStyle(color: TColor.textSecondary),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Отзывы о ваших услугах',
          style: TextStyle(
              color: TColor.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._reviews.map((r) {
          final client = r['client'] as Map<String, dynamic>? ?? {};
          final clientName = "${client['first_name'] ?? ''} ${client['last_name'] ?? ''}";
          final rating = r['rating']?.toDouble() ?? 0.0;
          final comment = r['comment']?.toString() ?? '';
          final createdAtIso = r['created_at']?.toString() ?? '';
          DateTime? createdAtDt = DateTime.tryParse(createdAtIso);
          final createdAt = createdAtDt != null
              ? DateFormat('dd MMM yyyy').format(createdAtDt.toLocal())
              : '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: TextStyle(
                        color: TColor.textPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: TColor.accent,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment,
                    style: TextStyle(color: TColor.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  if (createdAt.isNotEmpty)
                    Text(
                      createdAt,
                      style: TextStyle(
                          color: TColor.textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNavigationTile() {
    return Column(
      children: [
        const Divider(),
        ListTile(
          onTap: () {
            // «История заказов»
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CleanerOrdersScreen()),
            );
          },
          leading: Icon(Icons.history, color: TColor.primary),
          title: Text(
            "История заказов",
            style: TextStyle(
                color: TColor.textPrimary,
                fontWeight: FontWeight.bold),
          ),
          trailing:
          Icon(Icons.chevron_right, color: TColor.textPrimary),
        ),
        ListTile(
          onTap: () {
            // «Поддержка»
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen() /* тут ваш SupportScreen */),
            );
          },
          leading: Icon(Icons.support_agent, color: TColor.primary),
          title: Text(
            "Поддержка",
            style: TextStyle(
                color: TColor.textPrimary,
                fontWeight: FontWeight.bold),
          ),
          trailing:
          Icon(Icons.chevron_right, color: TColor.textPrimary),
        ),
        ListTile(
          onTap: () {
            // «О нас»
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen() /* тут ваш AboutUsScreen */),
            );
          },
          leading: Icon(Icons.info_outline, color: TColor.primary),
          title: Text(
            "О нас",
            style: TextStyle(
                color: TColor.textPrimary,
                fontWeight: FontWeight.bold),
          ),
          trailing:
          Icon(Icons.chevron_right, color: TColor.textPrimary),
        ),
      ],
    );
  }
}
