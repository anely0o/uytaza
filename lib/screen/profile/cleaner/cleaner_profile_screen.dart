import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  // controllers
  final _firstNameCtl = TextEditingController();
  final _lastNameCtl  = TextEditingController();
  final _phoneCtl     = TextEditingController();
  final _dobCtl       = TextEditingController();
  // gender
  String? _selectedGender;
  final _genders = ['male', 'female', 'other'];

  // data
  Map<String, dynamic> _initialData = {};
  int    _currentLevel    = 0;
  int    _xpTotal         = 0;
  double _rating          = 0.0;
  int    _reviewsCount        = 0;
  double _experienceYears = 0.0;


  bool   _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCleanerInfo();
  }

  Future<void> _loadCleanerInfo() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.getWithToken(ApiRoutes.profile);
      if (res.statusCode != 200) {
        throw Exception('Profile error ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      _initialData = data;

      // учитываем оба варианта ключей
      _firstNameCtl.text = data['FirstName']      ?? data['first_name']    ?? '';
      _lastNameCtl.text  = data['LastName']       ?? data['last_name']     ?? '';
      _phoneCtl.text     = data['PhoneNumber']    ?? data['phone_number']  ?? '';
      final dobRaw       = data['DateOfBirth']    ?? data['date_of_birth'] ?? '';
      _dobCtl.text       = (dobRaw as String).split('T')[0];
      final genderRaw    = data['Gender']         ?? data['gender'];
      _selectedGender    = _genders.contains(genderRaw) ? genderRaw : null;

      _rating       = (data['average_rating'] as num?)?.toDouble() ?? 0.0;
      _reviewsCount = (data['rating_count']   as num?)?.toInt()    ?? 0;

      // уровень и XP
      final stat = await ApiService.getWithToken(ApiRoutes.gamificationStatus);
      if (stat.statusCode == 200) {
        final sd = jsonDecode(stat.body) as Map<String, dynamic>;
        _currentLevel = (sd['current_level'] as num).toInt();
        _xpTotal      = (sd['xp_total']     as num).toInt();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _pickNewAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    try {
      await ApiService.uploadAvatar(File(img.path));
      setState(() {}); // обновить FutureBuilder
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'))
      );
    }
  }

  String _fixHost(String url) {
    return url.replaceFirst('localhost:9000', '10.0.2.2:9000');
  }

  Future<String?> _fetchLatestAvatarUrl() async {
    try {
      final raw = await ApiService.getLatestAvatarUrl();
      return raw == null ? null : _fixHost(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateProfile() async {
    final upd = <String,dynamic>{};
    if (_firstNameCtl.text != (_initialData['first_name'] ?? '')) {
      upd['first_name'] = _firstNameCtl.text;
    }
    if (_lastNameCtl.text != (_initialData['last_name'] ?? '')) {
      upd['last_name'] = _lastNameCtl.text;
    }
    if (_phoneCtl.text != (_initialData['phone_number'] ?? '')) {
      upd['phone_number'] = _phoneCtl.text;
    }
    final oldDob = (_initialData['date_of_birth'] as String? ?? '').split('T')[0];
    if (_dobCtl.text != oldDob) {
      upd['date_of_birth'] = '${_dobCtl.text}T00:00:00Z';
    }
    if (_selectedGender != (_initialData['gender'] ?? '')) {
      upd['gender'] = _selectedGender;
    }
    if (upd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes'))
      );
      return;
    }
    try {
      await ApiService.updateProfile(upd);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated'))
      );
      await _loadCleanerInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: TColor.primary,
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    final fullName = '${_firstNameCtl.text} ${_lastNameCtl.text}'.trim();
    final email    = _initialData['email'] as String? ?? '';

    return Scaffold(
      backgroundColor: TColor.primary,
      body: Column(
        children: [
          _buildHeader(fullName, email),
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
                  _buildEditableField(Icons.person_outline, 'Last Name',  _lastNameCtl),
                  _buildEditableField(Icons.phone, 'Phone', _phoneCtl),
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

  Widget _buildHeader(String fullName, String email) {
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
          FutureBuilder<String?>(
            future: _fetchLatestAvatarUrl(),
            builder: (ctx, snap) {
              if (snap.hasError) {
                return Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.white));
              }
              if (snap.connectionState != ConnectionState.done) {
                return const CircleAvatar(
                  radius: 40,
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              final url = snap.data;
              return GestureDetector(
                onTap: _pickNewAvatar,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: url != null ? NetworkImage(url) : null,
                  child: url == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (_currentLevel > 0 || _xpTotal > 0)
            Text('Level $_currentLevel • XP $_xpTotal',
                style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(fullName.isNotEmpty ? fullName : 'Not specified',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildEditableField(
      IconData icon, String label, TextEditingController ctl) {
    return ListTile(
      leading: Icon(icon, color: TColor.primary),
      title: Text(label,
          style:
          TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Text(
        ctl.text.isNotEmpty ? ctl.text : 'Not specified',
        style: TextStyle(color: TColor.textSecondary),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: TColor.primary),
        onPressed: () => _showEditDialog(label, ctl),
      ),
    );
  }

  void _showEditDialog(String label, TextEditingController ctl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content:
        TextField(controller: ctl, decoration: InputDecoration(hintText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateProfile();
            },
            style: ElevatedButton.styleFrom(backgroundColor: TColor.primary),
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
      subtitle: Text(
        _dobCtl.text.isNotEmpty ? _dobCtl.text : 'Not specified',
        style: TextStyle(color: TColor.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final initial = _dobCtl.text.isNotEmpty
            ? DateTime.parse(_dobCtl.text)
            : DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          _dobCtl.text = picked.toIso8601String().split('T')[0];
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
          ..._genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
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
      title: Text('Rating: ${_rating.toStringAsFixed(1)}',
          style: TextStyle(color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: List.generate(5, (i) {
          return Icon(
            i < _rating.round() ? Icons.star : Icons.star_border,
            color: TColor.accent,
            size: 20,
          );
        }),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Jobs: $_reviewsCount', style: TextStyle(color: TColor.textSecondary)),
          const SizedBox(height: 4),
          Text('Exp: ${_experienceYears.toStringAsFixed(1)} y',
              style: TextStyle(color: TColor.textSecondary)),
        ],
      ),
    );
  }
}
