import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/api/api_service.dart';

class RateOfServiceScreen extends StatefulWidget {
  const RateOfServiceScreen({super.key});

  @override
  State<RateOfServiceScreen> createState() => _RateOfServiceScreenState();
}

class _RateOfServiceScreenState extends State<RateOfServiceScreen> {
  double rating = 0;
  int totalJobs = 0;
  double yearsExperience = 0;
  List<dynamic> reviews = [];
  String name = '';
  String phone = '';
  String email = '';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profileRes =
      await ApiService.getWithToken('/api/auth/profile');
      final ratingRes = await ApiService.getWithToken('/rating');
      final reviewRes = await ApiService.getWithToken('/reviews/me');

      if (profileRes.statusCode == 200) {
        final data = jsonDecode(profileRes.body);
        name =
            '${data["FirstName"] ?? data["first_name"] ?? ''} ${data["LastName"] ?? data["last_name"] ?? ''}'
                .trim();
        phone = data["PhoneNumber"] ?? data["phone_number"] ?? '';
        email = data["Email"] ?? data["email"] ?? '';
        totalJobs = data["JobsDone"] ?? 0;
        yearsExperience =
            (data["ExperienceYears"] ?? 0).toDouble();
      }

      if (ratingRes.statusCode == 200) {
        final data = jsonDecode(ratingRes.body);
        rating = (data["rating"] ?? 0).toDouble();
      }

      if (reviewRes.statusCode == 200) {
        reviews = jsonDecode(reviewRes.body);
      }
    } catch (e) {
      // You can log or show an error if desired
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // neutral navbar
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: TColor.primary),
        ),
        title: Text(
          "Rate for Service",
          style: TextStyle(
            color: TColor.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildPersonalInfo(),
            _buildReviews(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: context.width * 0.5,
          color: TColor.primary,
        ),
        Padding(
          padding: EdgeInsets.only(top: context.width * 0.2),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: TColor.softShadow,
            ),
            child: Column(
              children: [
                SizedBox(height: context.width * 0.15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star,
                        color: TColor.accent, size: 25),
                    const SizedBox(width: 8),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                          color: TColor.textSecondary,
                          fontSize: 17),
                    ),
                  ],
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: TColor.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(height: 1),
                Row(
                  children: [
                    _buildStatItem(
                        totalJobs.toString(), "Total Jobs"),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.black12,
                    ),
                    _buildStatItem(yearsExperience.toStringAsFixed(1),
                        "Years"),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: context.width * 0.08,
          child: CircleAvatar(
            radius: context.width * 0.15,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(context.width * 0.15),
              child: Image.asset(
                "assets/img/u2.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: TColor.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: TColor.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBlock("Phone", phone),
          _infoBlock("Email", email),
          const Divider(),
          Text(
            "Reviews",
            style: TextStyle(
              color: TColor.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        "$title: $value",
        style: TextStyle(
          color: TColor.textSecondary,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      children: reviews.map((r) {
        final reviewerName = r['reviewer_name'] ?? 'Anonymous';
        final comment = r['comment'] ?? '';
        final stars = (r['rating'] ?? 0).toDouble();

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            reviewerName,
            style: TextStyle(color: TColor.textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingBarIndicator(
                rating: stars,
                itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20.0,
                unratedColor: Colors.black12,
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: TextStyle(color: TColor.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
