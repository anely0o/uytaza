// lib/screen/support/ticket_chat_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';

class TicketChatScreen extends StatefulWidget {
  final String ticketId;
  final String subject;

  const TicketChatScreen({
    super.key,
    required this.ticketId,
    required this.subject,
  });

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;
  bool _loading = true;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Загружает все сообщения по текущему тикету
  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
    });
    try {
      final res = await ApiService.getWithToken(
        '/api/support/tickets/${widget.ticketId}/messages',
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        _messages = data.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      // Игнорируем сетевые ошибки
    } finally {
      setState(() {
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  /// Отправляет новое сообщение (только текст)
  Future<void> _sendMessage() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty) return;

    setState(() {
      _sending = true;
    });

    final body = {'text': msg};

    try {
      final res = await ApiService.postWithToken(
        '/api/support/tickets/${widget.ticketId}/messages',
        body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _msgController.clear();
        await _loadMessages();
      } else {
        throw 'Message send failed (${res.statusCode})';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  /// Прокрутка списка сообщений до последнего
  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Рисует отдельный «пузырёк» для одного сообщения
  Widget _buildMessage(Map<String, dynamic> msg) {
    final senderRole = ((msg['sender'] as String?) ?? '').toLowerCase();
    final text = msg['text'] as String? ?? '';

    // Определяем выравнивание: пользователь (user) — справа, остальные — слева
    final isUser = senderRole == 'user';
    final alignment =
    isUser ? Alignment.centerRight : Alignment.centerLeft;

    // Выбираем цвет фона в зависимости от роли
    Color backgroundColor;
    Color textColor;
    if (senderRole == 'manager' || senderRole == 'admin') {
      backgroundColor = Colors.yellow.shade200;
      textColor = Colors.black87;
    } else {
      // user и cleaner — белый фон
      backgroundColor = Colors.white;
      textColor = TColor.textPrimary;
    }

    // Скругления: у пользователя скругляем нижний левый угол (пузырёк с правой стороны)
    final borderRadius = isUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(4),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(16),
    );

    // Формируем подпись: 'You' для пользователя, иначе название роли с заглавной буквы
    String roleLabel;
    if (senderRole == 'user') {
      roleLabel = 'You';
    } else if (senderRole == 'cleaner') {
      roleLabel = 'Cleaner';
    } else if (senderRole == 'manager') {
      roleLabel = 'Manager';
    } else if (senderRole == 'admin') {
      roleLabel = 'Admin';
    } else {
      // На всякий случай, если придёт неизвестная роль
      roleLabel =
      senderRole.isNotEmpty ? '${senderRole[0].toUpperCase()}${senderRole.substring(1)}' : '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              boxShadow: TColor.softShadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 4),
                Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
        title: Text(
          widget.subject,
          style: TextStyle(
            color: TColor.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: TColor.softShadow,
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle:
                              TextStyle(color: TColor.placeholder),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              if (!_sending) _sendMessage();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: TColor.primary),
                          onPressed: _sending ? null : _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
