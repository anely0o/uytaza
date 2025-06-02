import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';

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
    try {
      final res = await ApiService.getWithToken('/api/notifications');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        _items = decoded.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiService.putWithToken('/api/notifications/$id/read', {});
    } catch (_) {
      // ignore
    }
  }

  void _onTapNotification(Map<String, dynamic> notif) async {
    if (!(notif['read'] as bool? ?? false)) {
      await _markAsRead(notif['id']);
      setState(() {
        notif['read'] = true;
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
        : _items.where((n) => !(n['read'] as bool? ?? false)).toList();

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: TColor.primary,
        elevation: 0,
        actions: [
          Switch(
            value: _showRead,
            activeColor: Colors.white,
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
        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final n = filteredItems[i];
          final isRead = (n['read'] as bool?) ?? false;

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
                color: isRead ? Colors.white : TColor.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                leading: Icon(
                  isRead
                      ? Icons.mark_email_read
                      : Icons.mark_email_unread,
                  color: isRead ? Colors.grey : TColor.primary,
                ),
                title: Text(
                  n['title']?.toString() ?? 'Notification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryText,
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
                      color: TColor.secondaryText, fontSize: 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
