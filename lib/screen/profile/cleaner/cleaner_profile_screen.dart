// lib/screen/profile/cleaner/cleaner_profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/login/api_service.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({super.key});

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  bool _loading = true;
  bool _editing = false;

  final _nameCtl  = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  double? _rating;

  //--------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    await Future.wait([_loadProfile(), _loadRating()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadProfile() async {
    try {
      final r = await ApiService.getWithToken(ApiRoutes.cleanerProfile);
      if (r.statusCode == 200) {
        final m = jsonDecode(r.body);
        _nameCtl .text = m['first_name'] ?? '';
        _emailCtl.text = m['email']      ?? '';
        _phoneCtl.text = m['phone_number'] ?? '';
      } else {
        _show('Profile HTTP ${r.statusCode}');
      }
    } catch (e) {
      _show('Profile error: $e');
    }
  }

  Future<void> _loadRating() async {
    try {
      final r = await ApiService.getWithToken(ApiRoutes.cleanerRating);
      if (r.statusCode == 200) {
        final v = jsonDecode(r.body)['rating'];
        _rating = double.tryParse(v.toString());
      }
    } catch (_) {/* игнор */}
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final body = {
      'first_name'  : _nameCtl.text.trim(),
      'phone_number': _phoneCtl.text.trim(),
    };
    try {
      final r = await ApiService.putWithToken(ApiRoutes.cleanerProfile, body);
      if (r.statusCode == 200) {
        _show('Profile updated');
        setState(() => _editing = false);
      } else {
        _show('Save HTTP ${r.statusCode}');
      }
    } catch (e) {
      _show('Save error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  //--------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.card,
        elevation: 1,
        centerTitle: true,
        title: Text('Profile',
            style: TextStyle(
                color: TColor.primaryText, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _avatarBlock(),
          const SizedBox(height: 24),
          _field(label: 'Name',  ctl: _nameCtl,  enable: _editing),
          const SizedBox(height: 16),
          _field(label: 'Email', ctl: _emailCtl, enable: false),
          const SizedBox(height: 16),
          _field(label: 'Phone', ctl: _phoneCtl, enable: _editing),
          const SizedBox(height: 30),
          RoundButton(
            title : _editing ? 'Save' : 'Edit profile',
            onPressed: _editing ? _save : () => setState(() => _editing = true),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------
  Widget _avatarBlock() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: TColor.card,
      borderRadius: BorderRadius.circular(20),
      boxShadow: TColor.softShadow,
    ),
    child: Row(
      children: [
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nameCtl.text.isEmpty ? 'No name' : _nameCtl.text,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: TColor.primaryText)),
                const SizedBox(height: 4),
                if (_rating != null)
                  Row(children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 18),
                    const SizedBox(width: 4),
                    Text('${_rating!.toStringAsFixed(1)} / 5',
                        style: TextStyle(color: TColor.secondaryText)),
                  ]),
              ]),
        )
      ],
    ),
  );

  Widget _field(
      {required String label,
        required TextEditingController ctl,
        required bool enable}) =>
      TextField(
        controller: ctl,
        enabled: enable,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  void _show(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}
