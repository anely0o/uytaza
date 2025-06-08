import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';
import '../../order/cleaner/cleaner_orders_screen.dart';
import '../settings_screen.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({Key? key}) : super(key: key);

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  final TextEditingController _firstNameCtl = TextEditingController();
  final TextEditingController _lastNameCtl = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['male', 'female', 'other'];

  Map<String, dynamic> _initialData = {};

  int _currentLevel = 0;
  int _xpTotal = 0;
  double _rating = 0.0;
  int _jobsDone = 0;
  double _experienceYears = 0.0;
  bool _loading = true;
  String? _error;
  String? _avatarUrl;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadCleanerInfo();
  }

  Future<void> _loadCleanerInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profileRes = await ApiService.getWithToken(ApiRoutes.profile);
      if (profileRes.statusCode != 200) throw 'Error ${profileRes.statusCode}';

      final profileData = jsonDecode(profileRes.body) as Map<String, dynamic>;
      _initialData = profileData;
      _firstNameCtl.text = profileData['first_name'] ?? '';
      _lastNameCtl.text = profileData['last_name'] ?? '';
      _phoneController.text = profileData['phone_number'] ?? '';
      _email = profileData['email'] ?? '';
      _avatarUrl = profileData['avatar_url']?.toString();

      String dob = profileData['date_of_birth'] ?? '';
      if (dob.isNotEmpty) dob = dob.split('T')[0];
      _dobController.text = dob;

      _selectedGender = _genders.contains(profileData['gender']) ? profileData['gender'] : null;

      _rating = (profileData['average_rating'] as num?)?.toDouble() ?? 0.0;
      _jobsDone = (profileData['jobs_done'] as num?)?.toInt() ?? 0;
      _experienceYears = (profileData['experience_years'] as num?)?.toDouble() ?? 0.0;

      final statusRes = await ApiService.getWithToken(ApiRoutes.gamificationStatus);
      if (statusRes.statusCode == 200) {
        final sd = jsonDecode(statusRes.body) as Map<String, dynamic>;
        _currentLevel = (sd['current_level'] as num).toInt();
        _xpTotal = (sd['xp_total'] as num).toInt();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickNewAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    try {
      await ApiService.uploadAvatar(File(img.path));
      setState(() => _avatarUrl = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<ImageProvider?> _loadAvatarWithToken() async {
    final token = await ApiService.getToken();
    if (token == null) return null;
    final uri = Uri.parse('${ApiService.baseUrl}/media/avatars');
    final client = HttpClient();
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    final response = await request.close();
    if (response.statusCode == 200) {
      final bytes = await consolidateHttpClientResponseBytes(response);
      return MemoryImage(bytes);
    }
    return null;
  }

  Future<void> _updateProfile() async {
    final updated = <String, dynamic>{};

    if (_firstNameCtl.text != (_initialData['first_name'] ?? '')) {
      updated['first_name'] = _firstNameCtl.text;
    }
    if (_lastNameCtl.text != (_initialData['last_name'] ?? '')) {
      updated['last_name'] = _lastNameCtl.text;
    }
    if (_phoneController.text != (_initialData['phone_number'] ?? '')) {
      updated['phone_number'] = _phoneController.text;
    }
    if (_dobController.text != (_initialData['date_of_birth'] ?? '').split('T')[0]) {
      updated['date_of_birth'] = '${_dobController.text}T00:00:00Z';
    }
    if (_selectedGender != (_initialData['gender'] ?? '')) {
      updated['gender'] = _selectedGender;
    }

    if (updated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes')));
      return;
    }

    try {
      await ApiService.updateProfile(updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      await _loadCleanerInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
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

    final fullName = (_firstNameCtl.text + ' ' + _lastNameCtl.text).trim();

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
                  _buildRatingTile(),
                  const SizedBox(height: 16),
                  _buildEditableField(Icons.person, 'First Name', _firstNameCtl),
                  _buildEditableField(Icons.person_outline, 'Last Name', _lastNameCtl),
                  _buildEditableField(Icons.phone, 'Phone Number', _phoneController),
                  _buildDateField(),
                  _buildGenderField(),
                  const SizedBox(height: 30),
                  _buildNavigationTile(),
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
          FutureBuilder<ImageProvider?>(
            future: _loadAvatarWithToken(),
            builder: (context, snapshot) {
              final image = snapshot.data;
              return GestureDetector(
                onTap: _pickNewAvatar,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: image,
                  child: image == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (_currentLevel > 0 || _xpTotal > 0)
            Text('Level $_currentLevel • XP $_xpTotal', style: const TextStyle(color: Colors.white70)),
          if (_currentLevel > 0 || _xpTotal > 0) const SizedBox(height: 4),
          Text(fullName.isNotEmpty ? fullName : 'Not specified', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_email, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          const Text("Cleaner", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildEditableField(IconData icon, String label, TextEditingController controller) {
    return ListTile(
      leading: Icon(icon, color: TColor.primary),
      title: Text(label, style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Text(controller.text.isNotEmpty ? controller.text : 'Not specified', style: TextStyle(color: TColor.textSecondary)),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: TColor.primary),
        onPressed: () => _editFieldDialog(label, controller),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateProfile();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return ListTile(
      leading: Icon(Icons.cake, color: TColor.primary),
      title: const Text('Date of Birth'),
      subtitle: Text(_dobController.text.isNotEmpty ? _dobController.text : 'Not specified', style: TextStyle(color: TColor.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final initialDate = _dobController.text.isNotEmpty ? DateTime.parse(_dobController.text) : DateTime.now();
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
      title: const Text('Gender'),
      trailing: DropdownButton<String?>(
        value: _selectedGender,
        items: [
          const DropdownMenuItem(value: null, child: Text('Not specified')),
          ..._genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        ],
        onChanged: (val) {
          setState(() => _selectedGender = val);
          _updateProfile();
        },
      ),
    );
  }

  Widget _buildRatingTile() {
    return ListTile(
      leading: Icon(Icons.star, color: TColor.primary),
      title: Text("Rating: ${_rating.toStringAsFixed(1)}", style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: List.generate(5, (i) => Icon(i < _rating.round() ? Icons.star : Icons.star_border, color: TColor.accent, size: 20)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Jobs: $_jobsDone', style: TextStyle(color: TColor.textSecondary)),
          const SizedBox(height: 4),
          Text('Exp: ${_experienceYears.toStringAsFixed(1)} y', style: TextStyle(color: TColor.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNavigationTile() {
    return Column(
      children: [
        const Divider(),
        ListTile(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CleanerOrdersScreen())),
          leading: Icon(Icons.history, color: TColor.primary),
          title: Text("History", style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
          trailing: Icon(Icons.chevron_right, color: TColor.textPrimary),
        ),
      ],
    );
  }
}
