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
  bool _showRead = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // GET /api/notifications
      final res = await ApiService.getWithToken('/api/notifications');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        _items = decoded.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      // игнорируем ошибки сети
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      // PUT /api/notifications/:id/read
      await ApiService.putWithToken('/api/notifications/$id/read', {});
    } catch (_) {
      // игнорируем
    }
  }

  void _onTapNotification(Map<String, dynamic> notif) async {
    final isRead = (notif['is_read'] as bool?) ?? false;
    if (!isRead) {
      await _markAsRead(notif['id'].toString());
      setState(() {
        notif['is_read'] = true;
      });
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(notif['title'] ?? 'Notification'),
        content: Text(notif['body'] ?? ''),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Switch(
            value: _showRead,
            activeColor: TColor.primary,
            onChanged: (val) => setState(() => _showRead = val),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : filteredItems.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final n = filteredItems[i];
          final isRead = (n['is_read'] as bool?) ?? false;

          // Форматирование времени
          String formattedTime = '';
          final createdAt = n['created_at'] as String?;
          if (createdAt != null) {
            final dt = DateTime.tryParse(createdAt);
            if (dt != null) {
              formattedTime =
                  DateFormat('dd MMM, HH:mm').format(dt.toLocal());
            }
          }

          return GestureDetector(
            onTap: () => _onTapNotification(n),
            child: Container(
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.white
                    : TColor.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: TColor.softShadow,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                leading: Icon(
                  isRead
                      ? Icons.mark_email_read
                      : Icons.mark_email_unread,
                  color: isRead ? TColor.textSecondary : TColor.primary,
                ),
                title: Text(
                  n['title']?.toString() ?? 'Notification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.textPrimary,
                  ),
                ),
                subtitle: Text(
                  n['body']?.toString() ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  formattedTime,
                  style: TextStyle(
                      color: TColor.textSecondary, fontSize: 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
