// profile_router_screen.dart
import 'package:flutter/material.dart';
import 'package:uytaza/screen/profile/user_config.dart';
import 'package:uytaza/screen/profile/admin_profile_screen.dart';
import 'package:uytaza/screen/profile/client/client_profile_screen.dart';
import 'package:uytaza/screen/profile/cleaner/cleaner_profile_screen.dart';
import 'package:uytaza/screen/login/api_service.dart';

class ProfileRouterScreen extends StatefulWidget {
  const ProfileRouterScreen({super.key});

  @override
  State<ProfileRouterScreen> createState() => _ProfileRouterScreenState();
}

class _ProfileRouterScreenState extends State<ProfileRouterScreen> {
  UserRole? _userRole;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await ApiService.getUserRole();
      if (mounted) {
        setState(() {
          _userRole = role;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_userRole == null) {
      return Scaffold(
        body: Center(child: Text('User role not found')),
      );
    }

    switch (_userRole!) {
      case UserRole.admin:
        return const AdminProfileScreen();
      case UserRole.client:
        return const ClientProfileScreen();
      case UserRole.cleaner:
        return const CleanerProfileScreen();
    }
  }
}