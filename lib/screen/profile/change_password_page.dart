import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final bool isInitial; // true — установка пароля после временного

  const ChangePasswordPage({super.key, this.isInitial = false});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (widget.isInitial) {
        await ApiService.setInitialPassword(
          _oldController.text, _newController.text,
        );
      } else {
        await ApiService.changePassword(
          _oldController.text, _newController.text,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendPassword() async {
    setState(() => _loading = true);
    try {
      final email = await ApiService.getEmail();
      await ApiService.resendPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check your email for temporary password')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isInitial = widget.isInitial;

    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        title: Text(isInitial ? 'Set New Password' : 'Change Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: TColor.softShadow,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isInitial ? 'Temporary Password' : 'Current Password',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Text('Submit'),
              ),
              const SizedBox(height: 12),
              if (!isInitial)
                TextButton(
                  onPressed: _resendPassword,
                  child: const Text('Forgot current password?'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
