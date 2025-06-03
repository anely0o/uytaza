import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/order/cleaner/cleaner_orders_screen.dart';
import 'package:uytaza/screen/profile/client/settings_screen.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({super.key});

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  double rating = 0.0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCleanerProfile();
  }

  Future<void> _loadCleanerProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profileRes = await ApiService.getWithToken('/api/auth/profile');
      final ratingRes = await ApiService.getWithToken('/rating');

      if (profileRes.statusCode == 200) {
        final data = jsonDecode(profileRes.body);
        firstNameController.text = data['FirstName'] ?? data['first_name'] ?? '';
        lastNameController.text = data['LastName'] ?? data['last_name'] ?? '';
        emailController.text = data['Email'] ?? data['email'] ?? '';
        phoneController.text =
            data['PhoneNumber'] ?? data['phone_number'] ?? '';
      } else {
        _error = 'Ошибка загрузки профиля';
      }

      if (ratingRes.statusCode == 200) {
        final ratingData = jsonDecode(ratingRes.body);
        rating = double.tryParse(ratingData['rating'].toString()) ?? 0.0;
      }
    } catch (e) {
      _error = 'Ошибка: $e';
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateField(String key, String value) async {
    try {
      final response = await ApiService.putWithToken('/api/auth/profile', {
        key: value,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлён')),
        );
        _loadCleanerProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при обновлении профиля')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: TColor.softShadow,
              ),
              child: ListView(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                children: [
                  _buildInfoTile(
                    icon: Icons.email,
                    title: "Email",
                    subtitle: emailController.text,
                    controller: emailController,
                    fieldKey: "email",
                  ),
                  _buildInfoTile(
                    icon: Icons.phone,
                    title: "Phone Number",
                    subtitle: phoneController.text,
                    controller: phoneController,
                    fieldKey: "phone_number",
                  ),
                  _buildRatingTile(),
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
                const Expanded(
                  child: Center(
                    child: Text(
                      "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
            "${firstNameController.text} ${lastNameController.text}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < rating.round() ? Icons.star : Icons.star_border,
                color: TColor.accent,
                size: 20,
              );
            }),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String fieldKey,
  }) {
    return ListTile(
      leading: Icon(icon, color: TColor.primary),
      title: Text(
        title,
        style: TextStyle(
          color: TColor.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: TColor.textSecondary),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: TColor.primary),
        onPressed: () => _editFieldDialog(title, controller, fieldKey),
      ),
    );
  }

  Widget _buildRatingTile() {
    return ListTile(
      leading: Icon(Icons.star, color: TColor.primary),
      title: Text(
        "Rating",
        style: TextStyle(
          color: TColor.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: List.generate(5, (index) {
          return Icon(
            index < rating.round() ? Icons.star : Icons.star_border,
            color: TColor.accent,
            size: 20,
          );
        }),
      ),
    );
  }

  Widget _buildNavigationTile() {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CleanerOrdersScreen()),
        );
      },
      leading: Icon(Icons.list_alt, color: TColor.primary),
      title: Text(
        "Assigned Orders",
        style: TextStyle(
          color: TColor.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: TColor.textPrimary),
    );
  }

  void _editFieldDialog(
      String label, TextEditingController controller, String key) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $label"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _updateField(key, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
