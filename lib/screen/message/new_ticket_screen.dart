import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  File? _selectedImage;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill subject and message')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final ticketRes = await ApiService.postWithToken(
        '/api/support/tickets',
        {'subject': subject},
      );

      if (ticketRes.statusCode != 201) {
        throw 'Ticket creation failed (${ticketRes.statusCode})';
      }

      final ticketId = (Map<String, dynamic>.from(
          await ApiService.decodeJson(ticketRes)))
      ['id']
          .toString();

      final messageBody = {
        'text': message,
        'ticket_id': ticketId,
      };

      final msgRes = _selectedImage == null
          ? await ApiService.postWithToken(
          '/api/support/messages', messageBody)
          : await ApiService.postMultipart(
        '/api/support/messages',
        fileField: 'image',
        file: _selectedImage!,
        fields:
        messageBody.map((k, v) => MapEntry(k, v.toString())),
      );

      if (msgRes.statusCode == 200 || msgRes.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        throw 'Message failed (${msgRes.statusCode})';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.secondary,
      appBar: AppBar(
        title: const Text('New Ticket'),
        backgroundColor: TColor.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Subject", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: 'Enter subject...',
              hintStyle: TextStyle(color: TColor.placeholder),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Message", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _messageController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Describe your issue...',
              hintStyle: TextStyle(color: TColor.placeholder),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Attach Image"),
            ),
            const SizedBox(width: 12),
            if (_selectedImage != null)
              const Text("Image selected", style: TextStyle(fontSize: 13)),
          ]),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: TColor.primary),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Ticket"),
            ),
          )
        ]),
      ),
    );
  }
}
