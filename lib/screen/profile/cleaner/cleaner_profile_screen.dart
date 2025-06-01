import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/order/cleaner/cleaner_orders_screen.dart';
import 'package:uytaza/screen/profile/client/settings_screen.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({super.key});

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  final TextEditingController firstNameController = TextEditingController(
    text: "John",
  );
  final TextEditingController lastNameController = TextEditingController(
    text: "Smith",
  );
  final TextEditingController emailController = TextEditingController(
    text: "cleaner@example.com",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "87001112233",
  );

  double rating = 4.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                children: [
                  _buildInfoTile(
                    icon: Icons.email,
                    title: "Email",
                    subtitle: emailController.text,
                    controller: emailController,
                  ),
                  _buildInfoTile(
                    icon: Icons.phone,
                    title: "Phone Number",
                    subtitle: phoneController.text,
                    controller: phoneController,
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
                      "Cleaner Profile",
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
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _changeAvatarDialog,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _editNameDialog,
            child: Text(
              "${firstNameController.text} ${lastNameController.text}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return ListTile(
      leading: Icon(icon, color: TColor.secondary),
      title: Text(
        title,
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: TColor.secondaryText)),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: TColor.primary),
        onPressed: () => _editFieldDialog(title, controller),
      ),
    );
  }

  Widget _buildRatingTile() {
    return ListTile(
      leading: Icon(Icons.star, color: TColor.secondary),
      title: Text(
        "Rating",
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: List.generate(5, (index) {
          return Icon(
            index < rating.round() ? Icons.star : Icons.star_border,
            color: Colors.orange,
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
      leading: Icon(Icons.list_alt, color: TColor.secondary),
      title: Text(
        "Assigned Orders",
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  void _editNameDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Name"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "First Name"),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Last Name"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _editFieldDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _changeAvatarDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Change Avatar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Choose from Gallery"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a Photo"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }
}
