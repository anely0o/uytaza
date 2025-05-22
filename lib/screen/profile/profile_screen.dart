import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/login/api_service.dart';
import 'dart:convert';

import 'settings_screen.dart';

import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/login/api_service.dart';
import 'dart:convert';

import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _subscriptionController = TextEditingController(text: "Choose your plan");
  final TextEditingController _roleController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['male', 'female', 'other'];

  Map<String, dynamic> _initialData = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getWithToken('/api/auth/profile');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _initialData = Map<String, dynamic>.from(data);
          _emailController.text = data['Email'] ?? '';
          _firstNameController.text = data['FirstName'] ?? '';
          _lastNameController.text = data['LastName'] ?? '';
          _phoneController.text = data['PhoneNumber'] ?? '';
          _addressController.text = data['Address'] ?? '';

          String dob = data['DateOfBirth'] ?? '';
          if (dob.isNotEmpty) {
            dob = dob.split('T')[0];
            if (dob == '0001-01-01') dob = '';
          }
          _dobController.text = dob;

          _selectedGender = data['Gender'];
          _roleController.text = data['Role'] ?? 'Client';
          _loading = false;
        });
      } else {
        _showError('Ошибка загрузки профиля');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  Future<void> _updateProfile() async {
    final updatedFields = <String, dynamic>{};

    if (_firstNameController.text != (_initialData['FirstName'] ?? '')) {
      updatedFields['FirstName'] = _firstNameController.text;
    }
    if (_lastNameController.text != (_initialData['LastName'] ?? '')) {
      updatedFields['LastName'] = _lastNameController.text;
    }
    if (_phoneController.text != (_initialData['PhoneNumber'] ?? '')) {
      updatedFields['PhoneNumber'] = _phoneController.text;
    }
    if (_addressController.text != (_initialData['Address'] ?? '')) {
      updatedFields['Address'] = _addressController.text;
    }

    final oldDob = (_initialData['DateOfBirth'] ?? '').split('T')[0];
    if (_dobController.text != oldDob) {
      if (_dobController.text.isNotEmpty &&
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_dobController.text)) {
        _showError('Неверный формат даты. Используйте ГГГГ-ММ-ДД');
        return;
      }
      updatedFields['DateOfBirth'] = _dobController.text.isNotEmpty
          ? '${_dobController.text}T00:00:00Z'
          : '';
    }

    if (_selectedGender != null &&
        _selectedGender != (_initialData['Gender'] ?? '')) {
      updatedFields['Gender'] = _selectedGender;
    }

    if (updatedFields.isEmpty) {
      _showError('Нет изменений для сохранения');
      return;
    }

    try {
      final response = await ApiService.putWithToken('/api/auth/profile', updatedFields);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлён')),
        );
        await _loadProfile();
      } else {
        final data = json.decode(response.body);
        _showError(data['error'] ?? 'Ошибка обновления');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

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
                    subtitle: _emailController.text,
                    editable: false,
                  ),
                  _buildInfoTile(
                    icon: Icons.person,
                    title: "First Name",
                    subtitle: _firstNameController.text,
                    controller: _firstNameController,
                  ),
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: "Last Name",
                    subtitle: _lastNameController.text,
                    controller: _lastNameController,
                  ),
                  _buildInfoTile(
                    icon: Icons.phone,
                    title: "Phone Number",
                    subtitle: _phoneController.text,
                    controller: _phoneController,
                    helper: "Mobile",
                  ),
                  _buildClickableTile(
                    icon: Icons.location_on,
                    title: "Address",
                    value: _addressController.text,
                    controller: _addressController,
                  ),
                  _buildClickableTile(
                    icon: Icons.cake,
                    title: "Date of Birth",
                    value: _dobController.text,
                    controller: _dobController,
                  ),
                  _buildGenderTile(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final fullName = "${_firstNameController.text} ${_lastNameController.text}".trim();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
              fullName.isNotEmpty ? fullName : "Не указано",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _roleController.text,
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
    TextEditingController? controller,
    String? helper,
    bool editable = true,
  }) {
    final displayText = subtitle.isNotEmpty ? subtitle : "Нет данных";

    return ListTile(
      leading: Icon(icon, color: TColor.secondary),
      title: Text(
        title,
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: helper != null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            helper,
            style: TextStyle(color: TColor.secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(displayText, style: TextStyle(color: TColor.secondaryText)),
        ],
      )
          : Text(displayText, style: TextStyle(color: TColor.secondaryText)),
      trailing: editable
          ? IconButton(
        onPressed: () => _editFieldDialog(title, controller!),
        icon: Icon(Icons.edit, color: TColor.primary),
      )
          : null,
    );
  }

  Widget _buildClickableTile({
    required IconData icon,
    required String title,
    required String value,
    required TextEditingController controller,
  }) {
    final displayValue = value.isNotEmpty ? value : "Нет данных";

    return ListTile(
      onTap: () => _editFieldDialog(title, controller),
      leading: Icon(icon, color: TColor.secondary),
      title: Text(
        title,
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      subtitle: Text(displayValue, style: TextStyle(color: TColor.secondaryText)),
    );
  }

  Widget _buildGenderTile() {
    return ListTile(
      leading: Icon(Icons.person_outline, color: TColor.secondary),
      title: Text(
        "Gender",
        style: TextStyle(
          color: TColor.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: DropdownButton<String?>(
        value: _selectedGender,
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text("Не указано", style: TextStyle(color: TColor.secondaryText)),
          ),
          ..._genders.map((String value) {
            return DropdownMenuItem<String?>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ],
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue;
          });
          _updateProfile();
        },
      ),
    );
  }

  void _editNameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
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
                _updateProfile();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editFieldDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _updateProfile();
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
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Change Avatar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a photo"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}