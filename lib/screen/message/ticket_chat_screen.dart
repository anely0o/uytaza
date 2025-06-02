import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';

class TicketChatScreen extends StatefulWidget {
  final String ticketId;
  final String subject;

  const TicketChatScreen({super.key, required this.ticketId, required this.subject});

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  File? _selectedImage;
  bool _sending = false;
  bool _loading = true;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final res = await ApiService.getWithToken('/api/support/tickets/${widget.ticketId}/messages');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() => _messages = List<Map<String, dynamic>>.from(data));
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _sendMessage() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty) return;

    setState(() => _sending = true);

    final body = {
      'text': msg,
      'ticket_id': widget.ticketId,
    };

    try {
      final res = _selectedImage == null
          ? await ApiService.postWithToken('/api/support/messages', body)
          : await ApiService.postMultipart(
        '/api/support/messages',
        fileField: 'image',
        file: _selectedImage!,
        fields: body.map((k, v) => MapEntry(k, v.toString())),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _msgController.clear();
        _selectedImage = null;
        _loadMessages();
      } else {
        throw 'Message send failed (${res.statusCode})';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isClient = msg['sender'] == 'client';
    final text = msg['text'] ?? '';
    final imageUrl = msg['image_url'];

    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isClient ? TColor.chatTextBG : TColor.chatTextBG2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(color: isClient ? Colors.white : TColor.primaryText),
              ),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.network(imageUrl),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.secondary,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        title: Text(widget.subject, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).viewInsets.bottom),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: TColor.placeholder),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
