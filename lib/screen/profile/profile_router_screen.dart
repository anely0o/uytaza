import 'package:flutter/material.dart';
import 'package:uytaza/screen/profile/user_config.dart';
import 'package:uytaza/screen/profile/admin_profile_screen.dart';
import 'package:uytaza/screen/profile/client/client_profile_screen.dart';
import 'package:uytaza/screen/profile/cleaner/cleaner_profile_screen.dart';

class ProfileRouterScreen extends StatelessWidget {
  const ProfileRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    switch (currentUserRole) {
      case UserRole.admin:
        return const AdminProfileScreen();
      case UserRole.client:
        return const ClientProfileScreen();
      case UserRole.cleaner:
        return const CleanerProfileScreen();
    }
  }
}
