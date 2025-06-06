// lib/screen/support/new_ticket_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
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
  bool _loading = false;

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
      // 1) Создаём тикет
      final ticketRes = await ApiService.postWithToken(
        '/api/support/tickets',
        {'subject': subject},
      );

      if (ticketRes.statusCode != 201) {
        throw 'Ticket creation failed (${ticketRes.statusCode})';
      }

      final ticketJson = jsonDecode(ticketRes.body) as Map<String, dynamic>;
      final ticketId = ticketJson['id'].toString();

      // 2) Отправляем первое сообщение (только текст)
      final messageBody = {'text': message};
      final msgRes = await ApiService.postWithToken(
        '/api/support/tickets/$ticketId/messages',
        messageBody,
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
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text('New Ticket'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Subject",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: 'Enter subject...',
              hintStyle: TextStyle(color: TColor.placeholder),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: TColor.divider)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: TColor.primary)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Message",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextField(
            controller: _messageController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Describe your issue...',
              hintStyle: TextStyle(color: TColor.placeholder),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: TColor.divider),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary),
              child: _loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ))
                  : const Text("Submit Ticket"),
            ),
          )
        ]),
      ),
    );
  }
}
