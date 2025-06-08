// lib/screen/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/login/sign_in_screen.dart';
import 'package:uytaza/screen/profile/change_password_page.dart';
import 'package:uytaza/screen/profile/about_us_screen.dart';
import 'package:uytaza/api/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
  }

  void _logout() async {
    try {
      final response =
      await ApiService.postWithToken('/api/auth/logout', {});
      if (response.statusCode == 200) {
        await ApiService.logout(); // удалить локальный токен
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log out. Try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('An error occurred during logout.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: TColor.softShadow,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            ListTile(
              leading: Icon(Icons.info_outline, color: TColor.primary),
              title: Text(
                'About Us',
                style: TextStyle(
                  color: TColor.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _navigateToAbout,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.lock_outline, color: TColor.primary),
              title: Text(
                'Change Password',
                style: TextStyle(
                  color: TColor.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _navigateToChangePassword,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: TColor.primary),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: TColor.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
