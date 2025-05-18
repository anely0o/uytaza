import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/common_widget/round_textfield.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController firstNameController = TextEditingController(
    text: "John",
  );
  final TextEditingController lastNameController = TextEditingController(
    text: "Doe",
  );
  final TextEditingController roleController = TextEditingController(
    text: "Client",
  );
  final TextEditingController addressController = TextEditingController(
    text: "Choose your address",
  );
  final TextEditingController emailController = TextEditingController(
    text: "examplee@gmail.com",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "87752704123",
  );
  final TextEditingController subscriptionController = TextEditingController(
    text: "Choose your plan",
  );

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
                    editable: true,
                    controller: emailController,
                  ),
                  _buildInfoTile(
                    icon: Icons.phone,
                    title: "Phone Number",
                    subtitle: phoneController.text,
                    editable: true,
                    controller: phoneController,
                    helper: "Mobile",
                  ),
                  _buildClickableTile(
                    icon: Icons.group,
                    title: "Subscription Plan",
                    value: subscriptionController.text,
                    onTap: () {
                      // TODO: open subscription screen
                    },
                  ),
                  _buildClickableTile(
                    icon: Icons.location_on,
                    title: "Address",
                    value: addressController.text,
                    onTap: () {
                      // TODO: open address selector
                    },
                  ),
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
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Details",
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
                    // TODO: Navigate to settings
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
          Text(
            roleController.text,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
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
    String? helper,
    bool editable = false,
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
      subtitle:
          helper != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    helper,
                    style: TextStyle(color: TColor.secondaryText, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: TColor.secondaryText)),
                ],
              )
              : Text(subtitle, style: TextStyle(color: TColor.secondaryText)),
      trailing:
          editable
              ? IconButton(
                onPressed: () => _editFieldDialog(title, controller),
                icon: Icon(Icons.edit, color: TColor.primary),
              )
              : null,
    );
  }

  Widget _buildClickableTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: TColor.secondary),
      title: Text(
        title,
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      subtitle: Text(value, style: TextStyle(color: TColor.secondaryText)),
    );
  }

  void _editFieldDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _editNameDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
}
