import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/profile/about_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      //TODO: persist setting with api
    });
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
    );
  }

  void _logout() {
    //logout logic
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            _buildNotificationTile(),
            const Divider(height: 1),
            _buildAboutTile(),
            const Divider(height: 1),
            _buildLogoutTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile() {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        'Notifications',
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      value: _notificationsEnabled,
      activeColor: TColor.secondary,
      onChanged: _toggleNotifications,
      secondary: Icon(Icons.notifications, color: TColor.secondary),
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: Icon(Icons.info_outline, color: TColor.secondary),
      title: Text(
        'About Us',
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: _navigateToAbout,
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: Icon(Icons.logout, color: TColor.secondary),
      title: Text(
        'Log Out',
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: _logout,
    );
  }
}
