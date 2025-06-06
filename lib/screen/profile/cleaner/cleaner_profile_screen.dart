// lib/screen/profile/cleaner_profile_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';
import '../../order/cleaner/cleaner_orders_screen.dart';
import '../settings_screen.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({Key? key}) : super(key: key);

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  final TextEditingController _firstNameCtl = TextEditingController();
  final TextEditingController _lastNameCtl  = TextEditingController();

  int    _currentLevel = 0;
  int    _xpTotal      = 0;

  double _rating = 0.0;
  int    _jobsDone = 0;
  double _experienceYears = 0.0;
  bool   _loading = true;
  String? _error;

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
      _reviews = [];
    });

    try {
      // 1) Текущий профиль клинера
      final profileRes = await ApiService.getWithToken(ApiRoutes.profile);
      if (profileRes.statusCode != 200) {
        throw 'Error ${profileRes.statusCode}';
      }
      final profileData = jsonDecode(profileRes.body) as Map<String, dynamic>;
      _firstNameCtl.text = (profileData['FirstName'] ?? profileData['first_name'] ?? '').toString();
      _lastNameCtl.text  = (profileData['LastName']  ?? profileData['last_name']  ?? '').toString();

      final cleanerId = (profileData['id'] ?? '').toString();

      // 2) Если есть ID, подтягиваем gamification (уровень + XP)
      if (cleanerId.isNotEmpty) {
        final statusRes = await ApiService.getWithToken(ApiRoutes.gamificationStatus);
        if (statusRes.statusCode == 200) {
          final sd = jsonDecode(statusRes.body) as Map<String, dynamic>;
          _currentLevel = (sd['current_level'] as num).toInt();
          _xpTotal      = (sd['xp_total'] as num).toInt();
        }

        // 3) Оценка, выполненные работы, опыт
        final ratingRes = await ApiService.getWithToken('${ApiRoutes.ratingCleaner}$cleanerId');
        if (ratingRes.statusCode == 200) {
          final rd = jsonDecode(ratingRes.body) as Map<String, dynamic>;
          _rating = (rd['rating'] ?? 0).toDouble();
          _jobsDone = (rd['jobs_done'] ?? 0) as int;
          _experienceYears = (rd['experience_years'] ?? 0).toDouble();
        }

        // 4) Отзывы
        final reviewsRes = await ApiService.getWithToken('${ApiRoutes.reviewsCleaner}$cleanerId');
        if (reviewsRes.statusCode == 200) {
          final list = jsonDecode(reviewsRes.body) as List<dynamic>;
          _reviews = list.whereType<Map<String, dynamic>>().toList();
        }
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: TColor.softShadow,
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                children: [
                  const SizedBox(height: 8),
                  _buildRatingTile(),
                  const SizedBox(height: 16),
                  _buildReviewsSection(),
                  const SizedBox(height: 30),
                  _buildNavigationTile(),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
          // Показываем уровень и XP над именем
          if (_currentLevel > 0 || _xpTotal > 0)
            Text(
              'Level $_currentLevel • XP $_xpTotal',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (_currentLevel > 0 || _xpTotal > 0)
            const SizedBox(height: 4),
          Text(
            '${_firstNameCtl.text} ${_lastNameCtl.text}'.trim(),
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Jobs: $_jobsDone',
            style: TextStyle(color: TColor.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Exp: ${_experienceYears.toStringAsFixed(1)} y',
            style: TextStyle(color: TColor.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (_reviews.isEmpty) {
      return Center(
        child: Text(
          'You have no reviews yet',
          style: TextStyle(color: TColor.textSecondary),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews of your services',
          style: TextStyle(
            color: TColor.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._reviews.map((r) {
          final client = r['client'] as Map<String, dynamic>? ?? {};
          final clientName = '${client['first_name'] ?? ''} ${client['last_name'] ?? ''}'.trim();
          final rating = (r['rating'] as num?)?.toDouble() ?? 0.0;
          final comment = r['comment']?.toString() ?? '';
          final createdAtIso = r['created_at']?.toString() ?? '';
          final createdAtDt = DateTime.tryParse(createdAtIso);
          final createdAt = createdAtDt != null
              ? DateFormat('dd MMM yyyy').format(createdAtDt.toLocal())
              : '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: TextStyle(
                      color: TColor.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
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
                      style: TextStyle(color: TColor.textSecondary, fontSize: 12),
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
            // Order history (opens CleanerOrdersScreen)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CleanerOrdersScreen()),
            );
          },
          leading: Icon(Icons.history, color: TColor.primary),
          title: Text(
            "History",
            style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.chevron_right, color: TColor.textPrimary),
        ),
      ],
    );
  }
}
