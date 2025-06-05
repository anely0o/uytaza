// lib/screen/support/ticket_chat_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
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
        _messages = data
            .whereType<Map<String, dynamic>>()
            .toList();
      } else {
        // Если сервер вернул ошибку — оставим _messages как есть
      }
    } catch (_) {
      // Игнорируем сетевые ошибки
    } finally {
      setState(() {
        _loading = false;
      });
      // После загрузки — прокрутить список вниз
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  /// Отправляет новое сообщение (текст + опционально картинку)
  Future<void> _sendMessage() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty && _selectedImage == null) return;

    setState(() {
      _sending = true;
    });

    final body = {'text': msg};

    try {
      late final dynamic res;
      if (_selectedImage == null) {
        // Отправляем только текст
        res = await ApiService.postWithToken(
          '/api/support/tickets/${widget.ticketId}/messages',
          body,
        );
      } else {
        // Отправляем картинку + текстовые поля
        res = await ApiService.postMultipart(
          '/api/support/tickets/${widget.ticketId}/messages',
          fileField: 'image',
          file: _selectedImage!,
          fields: body.map((k, v) => MapEntry(k, v.toString())),
        );
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Успешно отправлено — сбросить поля ввода
        _msgController.clear();
        _selectedImage = null;
        // Перезагрузить все сообщения
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

  /// Открывает галерею для выбора картинки
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
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
    final senderRole = (msg['sender'] as String?) ?? '';
    // Предположим, что "client" - это клиент, все остальные - поддержка
    final isClient = senderRole.toLowerCase() == 'client';

    final text = msg['text'] as String? ?? '';
    final imageUrl = msg['image_url'] as String?;

    // Скругления: у клиента скругляем нижний левый угол (пузырёк с правой стороны)
    final borderRadius = isClient
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isClient
                  ? TColor.primary.withOpacity(0.9)
                  : TColor.background,
              borderRadius: borderRadius,
              boxShadow: TColor.softShadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Если у сообщения есть текст — показываем его
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: TextStyle(
                      color: isClient ? Colors.white : TColor.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                // Если есть картинка — показываем картинку
                if (imageUrl != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                // Можно добавить timestamp или метку «Client» / «Support»
                const SizedBox(height: 4),
                Align(
                  alignment:
                  isClient ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    isClient ? 'You' : 'Support',
                    style: TextStyle(
                      fontSize: 10,
                      color: isClient ? Colors.white70 : TColor.textSecondary,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),
          // Поле ввода сообщения + кнопки
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                // Кнопка прикрепить файл (картинку)
                IconButton(
                  icon: Icon(Icons.attach_file, color: TColor.primary),
                  onPressed: _pickImage,
                ),
                const SizedBox(width: 8),
                // Само текстовое поле + кнопка отправить
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: TColor.softShadow,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        // Поле ввода текста
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(color: TColor.placeholder),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              if (!_sending) _sendMessage();
                            },
                          ),
                        ),
                        // Если выбрана картинка — показываем маленький предпросмотр
                        if (_selectedImage != null) ...[
                          const SizedBox(width: 8),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: TColor.divider),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Крестик, чтобы убрать прикреплённую картинку
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Кнопка «отправить»
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
