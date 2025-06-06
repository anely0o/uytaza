// lib/screen/notification/notifications_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  bool _showRead = false;
  // Набор ID уведомлений, которые сейчас развернуты (expanded)
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // GET /api/notifications
      final res = await ApiService.getWithToken('/api/notifications');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        _items = decoded
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    } catch (_) {
      // Игнорируем сетевые ошибки
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      // PUT /api/notifications/:id/read
      await ApiService.putWithToken('/api/notifications/$id/read', {});
    } catch (_) {
      // Игнорируем ошибки
    }
  }

  void _onExpansionChanged(bool expanded, String notifId) async {
    if (expanded) {
      // Если разворачиваем впервые и уведомление ещё не прочитано — помечаем его как прочитанное
      final idx = _items.indexWhere((n) => n['id'].toString() == notifId);
      if (idx != -1) {
        final isRead = _items[idx]['is_read'] as bool? ?? false;
        if (!isRead) {
          await _markAsRead(notifId);
          setState(() {
            _items[idx]['is_read'] = true;
          });
        }
      }
      _expandedIds.add(notifId);
    } else {
      _expandedIds.remove(notifId);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredItems = _showRead
        ? _items
        : _items.where((n) => !(n['is_read'] as bool? ?? false)).toList();

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
        actions: [
          // Переключатель "показывать прочитанные / только непрочитанные"
          Row(
            children: [
              Text(
                'Show read',
                style: TextStyle(color: TColor.textPrimary),
              ),
              Switch(
                value: _showRead,
                activeColor: TColor.primary,
                onChanged: (val) => setState(() => _showRead = val),
              ),
              const SizedBox(width: 8),
            ],
          )
        ],
      ),
      body: filteredItems.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final n = filteredItems[index];
          final id = n['id'].toString();
          final isRead = (n['is_read'] as bool?) ?? false;

          // Форматирование времени (если есть поле created_at)
          String formattedTime = '';
          final createdAt = n['created_at'] as String?;
          if (createdAt != null) {
            final dt = DateTime.tryParse(createdAt);
            if (dt != null) {
              formattedTime = DateFormat('dd MMM, HH:mm').format(dt.toLocal());
            }
          }

          // Заголовок и краткий текст для пункта списка
          final titleText = n['title']?.toString() ?? 'Notification';
          final bodyText = n['body']?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.white
                    : TColor.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: TColor.softShadow,
              ),
              child: ExpansionTile(
                key: PageStorageKey<String>(id),
                initiallyExpanded: _expandedIds.contains(id),
                onExpansionChanged: (expanded) => _onExpansionChanged(expanded, id),
                leading: Icon(
                  isRead
                      ? Icons.mark_email_read
                      : Icons.mark_email_unread,
                  color: isRead ? TColor.textSecondary : TColor.primary,
                ),
                title: Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.textPrimary,
                  ),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bodyText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: TColor.textSecondary),
                      ),
                    ),
                    if (formattedTime.isNotEmpty)
                      Text(
                        formattedTime,
                        style: TextStyle(
                            color: TColor.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Здесь выводим всю подробную информацию уведомления
                  Text(
                    bodyText,
                    style: TextStyle(
                      fontSize: 14,
                      color: TColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (n.containsKey('type'))
                    RichText(
                      text: TextSpan(
                        text: 'Type: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColor.textPrimary),
                        children: [
                          TextSpan(
                            text: n['type'].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: TColor.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  if (n.containsKey('data') && n['data'] is Map<String, dynamic>)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Data:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: TColor.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Перебираем ключи в объекте data
                          ...(n['data'] as Map<String, dynamic>).entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: TextStyle(
                                    color: TColor.textSecondary,
                                    fontSize: 13),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Created at: $formattedTime',
                      style: TextStyle(
                          fontSize: 12,
                          color: TColor.textSecondary,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
