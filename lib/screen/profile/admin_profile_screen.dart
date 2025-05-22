import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Profile")),
      body: const Center(
        child: Text(
          "Добро пожаловать, администратор!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
