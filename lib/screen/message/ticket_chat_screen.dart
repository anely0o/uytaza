// lib/screen/support/ticket_chat_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';

class TicketChatScreen extends StatefulWidget {
  final String ticketId;
  final String subject;
  final bool isReadOnly;

  const TicketChatScreen({
    super.key,
    required this.ticketId,
    required this.subject,
    this.isReadOnly = false,
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
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Загружает информацию о текущем пользователе
  Future<void> _loadCurrentUser() async {
    try {
      _currentUserEmail = await ApiService.getEmail();
    } catch (e) {
      print('Error loading current user email: $e');
    }
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
    if (widget.isReadOnly) return;

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

  /// Получает цветовую схему для роли
  Map<String, dynamic> _getRoleColors(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return {
          'background': Colors.yellow.shade50,
          'text': TColor.textPrimary,
          'accent': Colors.yellow.shade600,
          'border': Colors.yellow.shade200,
          'icon': Icons.admin_panel_settings,
        };
      case 'manager':
        return {
          'background': Colors.blue.shade50,
          'text': TColor.textPrimary,
          'accent': Colors.blue.shade600,
          'border': Colors.blue.shade200,
          'icon': Icons.support_agent,
        };
      case 'cleaner':
        return {
          'background': TColor.placeholder,
          'text': TColor.textPrimary,
          'accent': TColor.textSecondary,
          'border': TColor.textSecondary,
          'icon': Icons.cleaning_services,
        };
      case 'user':
      default:
        return {
          'background': TColor.placeholder,
          'text': TColor.textPrimary,
          'accent': TColor.textSecondary,
          'border': TColor.textSecondary,
          'icon': Icons.cleaning_services,
        };
    }
  }

  /// Форматирует время сообщения
  String _formatMessageTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return DateFormat('dd MMM, HH:mm').format(dateTime.toLocal());
      } else if (difference.inHours > 0) {
        return DateFormat('HH:mm').format(dateTime.toLocal());
      } else {
        return DateFormat('HH:mm').format(dateTime.toLocal());
      }
    } catch (e) {
      return '';
    }
  }

  /// Рисует отдельный «пузырёк» для одного сообщения
  Widget _buildMessage(Map<String, dynamic> msg) {
    final senderRole = ((msg['sender_role'] as String?) ?? 'user').toLowerCase();
    final senderEmail = msg['sender_email'] as String? ?? '';
    final text = msg['text'] as String? ?? '';
    final timestamp = msg['created_at'] as String?;

    // Определяем, является ли это сообщением текущего пользователя
    final isCurrentUser = senderEmail == _currentUserEmail;
    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Получаем цветовую схему для роли
    final colors = _getRoleColors(senderRole);
    final backgroundColor = colors['background'] as Color;
    final textColor = colors['text'] as Color;
    final accentColor = colors['accent'] as Color;
    final borderColor = colors['border'] as Color;
    final roleIcon = colors['icon'] as IconData;

    // Скругления пузырька
    final borderRadius = isCurrentUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(4),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(20),
    );

    // Формируем отображаемое имя роли
    String roleDisplayName;
    switch (senderRole) {
      case 'admin':
        roleDisplayName = 'Administrator';
        break;
      case 'manager':
        roleDisplayName = 'Support Manager';
        break;
      case 'cleaner':
        roleDisplayName = 'You';
        break;
      case 'user':
      default:
        roleDisplayName = 'You';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Заголовок с ролью и email (только для других пользователей)
          if (!isCurrentUser) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    roleIcon,
                    size: 16,
                    color: accentColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    roleDisplayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  if (senderEmail.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '• $senderEmail',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColor.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Пузырек сообщения
          Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (timestamp != null)
                          Text(
                            _formatMessageTime(timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subject,
              style: TextStyle(
                color: TColor.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  'Ticket #${widget.ticketId.substring(0, 8)}...',
                  style: TextStyle(
                    color: TColor.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (widget.isReadOnly) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CLOSED',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              icon: Icon(Icons.refresh, color: TColor.primary),
              onPressed: _loadMessages,
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.isReadOnly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Icon(Icons.history, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'This ticket is closed. You are viewing the history.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _loading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: TColor.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading messages...',
                    style: TextStyle(color: TColor.textSecondary),
                  ),
                ],
              ),
            )
                : _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: TColor.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: TColor.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isReadOnly
                        ? 'This ticket has no messages'
                        : 'Start the conversation!',
                    style: TextStyle(
                      color: TColor.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),

          // Поле ввода сообщения (скрыто для закрытых тикетов)
          if (!widget.isReadOnly)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: TColor.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: TColor.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: TextStyle(color: TColor.textSecondary),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) {
                                if (!_sending) _sendMessage();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _sending
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _sending ? null : _sendMessage,
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
