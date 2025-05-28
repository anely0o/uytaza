import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/login/api_service.dart';
import 'dart:convert';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({super.key});

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  bool _loading = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _role = 'Cleaner';
  double? _rating;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRating();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getWithToken('/api/auth/profile');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['first_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _role = data['role'] ?? 'Cleaner';
        });
      } else {
        _showError('Failed to load profile (${res.statusCode})');
      }
    } catch (e) {
      _showError('Error loading profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRating() async {
    try {
      final res = await ApiService.getWithToken('/api/auth/rating');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => _rating = double.tryParse(data['rating'].toString()));
      } else {
        _showError('Failed to load rating (${res.statusCode})');
      }
    } catch (e) {
      _showError('Error loading rating: $e');
    }
  }

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final body = {
      'first_name': _nameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
    };
    try {
      final res = await ApiService.putWithToken('/api/auth/profile', body);
      if (res.statusCode == 200) {
        _showMessage('Profile updated successfully');
        setState(() => _isEditing = false);
      } else {
        final data = jsonDecode(res.body) as Map<String, dynamic>?;
        _showError(data?['error'] ?? 'Update failed (${res.statusCode})');
      }
    } catch (e) {
      _showError('Error updating profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
    return Scaffold(
      backgroundColor: TColor.primary,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField('Name', _nameController, !_isEditing),
                    const SizedBox(height: 16),
                    _buildTextField('Email', _emailController, true),
                    const SizedBox(height: 16),
                    _buildTextField('Phone Number', _phoneController, !_isEditing),
                    const SizedBox(height: 24),
                    RoundButton(
                      title: _isEditing ? 'Save' : 'Edit Profile',
                      onPressed: () {
                        if (_isEditing) {
                          _updateProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        color: TColor.primary,
        child: Row(
          children: [
            const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.grey)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : 'No Name',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _role,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  if (_rating != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Rating: ${_rating!.toStringAsFixed(1)} / 5',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool enabled) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
