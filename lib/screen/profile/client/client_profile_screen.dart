import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/screen/profile/settings_screen.dart';
import '../../models/media_model.dart';
import 'choose_address_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  String? _error;


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['male', 'female', 'other'];

  Map<String, dynamic> _initialData = {};
  int _currentLevel = 0;
  int _xpTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.getWithToken('/api/auth/profile');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _initialData = Map<String, dynamic>.from(data);
          _emailController.text = data['Email'] ?? data['email'] ?? '';
          _firstNameController.text = data['FirstName'] ?? data['first_name'] ?? '';
          _lastNameController.text = data['LastName'] ?? data['last_name'] ?? '';
          _phoneController.text = data['PhoneNumber'] ?? data['phone_number'] ?? '';
          _addressController.text = data['Address'] ?? data['address'] ?? '';
          _roleController.text = data['Role'] ?? data['role'] ?? 'Client';

          String dob = data['DateOfBirth'] ?? data['date_of_birth'] ?? '';
          if (dob.isNotEmpty) {
            dob = dob.split('T')[0];
            if (dob == '0001-01-01') dob = '';
          }
          _dobController.text = dob;

          String? gender = data['Gender'] ?? data['gender'];
          if (!_genders.contains(gender)) {
            gender = null;
          }
          _selectedGender = gender;
        });

        final statusRes = await ApiService.getWithToken(ApiRoutes.gamificationStatus);
        if (statusRes.statusCode == 200) {
          final sd = jsonDecode(statusRes.body) as Map<String, dynamic>;
          setState(() {
            _currentLevel = (sd['current_level'] as num).toInt();
            _xpTotal = (sd['xp_total'] as num).toInt();
          });
        }

        setState(() => _loading = false);
      } else {
        setState(() => _error = 'Ошибка загрузки профиля: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Ошибка: $e');
    }
  }
  Future<void> _updateProfile() async {
    final updatedFields = <String, dynamic>{};

    if (_firstNameController.text != (_initialData['FirstName'] ?? _initialData['first_name'] ?? '')) {
      updatedFields['first_name'] = _firstNameController.text;
    }
    if (_lastNameController.text != (_initialData['LastName'] ?? _initialData['last_name'] ?? '')) {
      updatedFields['last_name'] = _lastNameController.text;
    }
    if (_phoneController.text != (_initialData['PhoneNumber'] ?? _initialData['phone_number'] ?? '')) {
      updatedFields['phone_number'] = _phoneController.text;
    }
    if (_addressController.text != (_initialData['Address'] ?? _initialData['address'] ?? '')) {
      updatedFields['address'] = _addressController.text;
    }

    final oldDob = (_initialData['DateOfBirth'] ?? _initialData['date_of_birth'] ?? '').split('T')[0];
    if (_dobController.text != oldDob) {
      if (_dobController.text.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_dobController.text)) {
        _showError('Неверный формат даты. Используйте ГГГГ-ММ-ДД');
        return;
      }
      if (_dobController.text.isNotEmpty) {
        updatedFields['date_of_birth'] = '${_dobController.text}T00:00:00Z';
      }
    }

    if (_selectedGender != (_initialData['Gender'] ?? _initialData['gender'] ?? '')) {
      updatedFields['gender'] = _selectedGender;
    }

    if (updatedFields.isEmpty) {
      _showError('Нет изменений для сохранения');
      return;
    }

    try {
      await ApiService.updateProfile(updatedFields);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль обновлён')),
      );
      await _loadProfile();
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }
  String _fixHost(String url) {
    return url.replaceFirst('localhost:9000', '10.0.2.2:9000');
  }

  Future<String?> _fetchLatestAvatarUrl() async {
    try {
      final rawUrl = await ApiService.getLatestAvatarUrl();
      if (rawUrl == null) return null;
      // Вот тут и «чините» хост
      return _fixHost(rawUrl);
    } catch (e) {
      print('Error fetching avatar: $e');
      return null;
    }
  }

  Future<void> _pickNewAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    try {
      await ApiService.uploadAvatar(File(img.path));
      setState(() { /* trigger reload */ });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Avatar updated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }



  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.white))),
      );
    }

    final fullName = (_firstNameController.text + ' ' + _lastNameController.text).trim();

    return Scaffold(
      backgroundColor: TColor.primary,
      body: Column(
        children: [
          _buildHeader(fullName),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: TColor.softShadow,
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                children: [
                  _buildReadonlyTile(Icons.email, 'Email', _emailController.text),
                  _buildEditableField(Icons.person, 'First Name', _firstNameController),
                  _buildEditableField(Icons.person_outline, 'Last Name', _lastNameController),
                  _buildEditableField(Icons.phone, 'Phone Number', _phoneController),
                  _buildAddressField(),
                  _buildDateField(),
                  _buildGenderField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String fullName) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          FutureBuilder<String?>(
            future: _fetchLatestAvatarUrl(),
            builder: (ctx, snap) {
              if (snap.hasError) {
                return Text('Error: ${snap.error}');
              }
              if (snap.connectionState != ConnectionState.done) {
                return const CircleAvatar(
                  radius: 40,
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              final URL = snap.data;
              print('Avatar URL = $URL');
              return GestureDetector(
                onTap: _pickNewAvatar,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  URL != null ? NetworkImage(URL) : null,
                  child: URL == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          if (_currentLevel > 0 || _xpTotal > 0)
            Text(
              'Level $_currentLevel • XP $_xpTotal',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (_currentLevel > 0 || _xpTotal > 0) const SizedBox(height: 4),
          Text(
            fullName.isNotEmpty ? fullName : 'Not specified',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
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

  Widget _buildReadonlyTile(IconData icon, String label, String value) {
    final displayText = value.isNotEmpty ? value : "Нет данных";
    return ListTile(
      leading: Icon(icon, color: TColor.primary),
      title: Text(label, style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Text(displayText, style: TextStyle(color: TColor.textSecondary)),
    );
  }

  Widget _buildEditableField(IconData icon, String label, TextEditingController controller) {
    final displayText = controller.text.isNotEmpty ? controller.text : "Нет данных";
    return ListTile(
      leading: Icon(icon, color: TColor.primary),
      title: Text(label, style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Text(displayText, style: TextStyle(color: TColor.textSecondary)),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: TColor.primary),
        onPressed: () => _editFieldDialog(label, controller),
      ),
    );
  }

  Widget _buildAddressField() {
    final displayValue = _addressController.text.isNotEmpty ? _addressController.text : "Нет данных";
    return ListTile(
      leading: Icon(Icons.location_on, color: TColor.primary),
      title: Text('Address', style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Text(displayValue, style: TextStyle(color: TColor.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final res = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const ChooseAddressScreen()),
        );
        if (res != null) {
          setState(() => _addressController.text = res);
          _updateProfile();
        }
      },
    );
  }

  Widget _buildDateField() {
    final displayValue = _dobController.text.isNotEmpty ? _dobController.text : "Нет данных";
    return ListTile(
      leading: Icon(Icons.cake, color: TColor.primary),
      title: Text('Date of Birth', style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Text(displayValue, style: TextStyle(color: TColor.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final initialDate = _dobController.text.isNotEmpty
            ? DateTime.parse(_dobController.text)
            : DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          final dateStr = picked.toIso8601String().split('T')[0];
          setState(() => _dobController.text = dateStr);
          _updateProfile();
        }
      },
    );
  }

  Widget _buildGenderField() {
    return ListTile(
      leading: Icon(Icons.person_outline, color: TColor.primary),
      title: Text('Gender', style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      trailing: DropdownButton<String?>(
        value: _selectedGender,
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text("Не указано", style: TextStyle(color: Colors.grey)),
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

  void _editFieldDialog(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateProfile();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: TColor.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
