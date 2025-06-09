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

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  bool _showRead = false;
  final Set<String> _expandedIds = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _load();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getWithToken('/api/notifications');
      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body);
        _items = decoded.whereType<Map<String, dynamic>>().toList();
        _fadeController.forward();
      }
    } catch (_) {
      // Игнорируем сетевые ошибки
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiService.putWithToken('/api/notifications/$id/read', {});
    } catch (_) {
      // Игнорируем ошибки
    }
  }

  void _onExpansionChanged(bool expanded, String notifId) async {
    if (expanded) {
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

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'cleaning_completed':
        return Icons.cleaning_services;
      case 'review_request':
        return Icons.rate_review;
      case 'order_assigned':
        return Icons.assignment;
      case 'payment':
        return Icons.payment;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type, bool isRead) {
    if (isRead) return TColor.textSecondary;

    switch (type?.toLowerCase()) {
      case 'cleaning_completed':
        return Colors.green;
      case 'review_request':
        return Colors.orange;
      case 'order_assigned':
        return TColor.primary;
      case 'payment':
        return Colors.purple;
      case 'reminder':
        return Colors.red;
      default:
        return TColor.primary;
    }
  }

  String _getRelativeTime(String? createdAt) {
    if (createdAt == null) return '';

    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dt.toLocal());

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(dt.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: TColor.background,
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: TColor.primary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: TColor.primary),
              const SizedBox(height: 16),
              Text(
                'Loading notifications...',
                style: TextStyle(color: TColor.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final filteredItems = _showRead
        ? _items
        : _items.where((n) => !(n['is_read'] as bool? ?? false)).toList();

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Show read',
                  style: TextStyle(
                    color: TColor.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _showRead,
                    activeColor: TColor.primary,
                    inactiveThumbColor: Colors.grey[300],
                    inactiveTrackColor: Colors.grey[200],
                    onChanged: (val) => setState(() => _showRead = val),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: filteredItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: TColor.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _showRead ? 'No notifications' : 'No unread notifications',
              style: TextStyle(
                fontSize: 18,
                color: TColor.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: TColor.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        color: TColor.primary,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final n = filteredItems[index];
              final id = n['id'].toString();
              final isRead = (n['is_read'] as bool?) ?? false;
              final type = n['type']?.toString();
              final titleText = n['title']?.toString() ?? 'Notification';
              final bodyText = n['body']?.toString() ?? '';
              final relativeTime = _getRelativeTime(n['created_at'] as String?);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  elevation: isRead ? 1 : 3,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isRead
                          ? null
                          : Border.all(
                        color: _getNotificationColor(type, false).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        expansionTileTheme: const ExpansionTileThemeData(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                        ),
                      ),
                      child: ExpansionTile(
                        key: PageStorageKey<String>(id),
                        initiallyExpanded: _expandedIds.contains(id),
                        onExpansionChanged: (expanded) => _onExpansionChanged(expanded, id),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getNotificationColor(type, isRead).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getNotificationIcon(type),
                            color: _getNotificationColor(type, isRead),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          titleText,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            color: TColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              bodyText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: TColor.textSecondary,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (!isRead) ...[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getNotificationColor(type, false),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  relativeTime,
                                  style: TextStyle(
                                    color: TColor.textSecondary.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: AnimatedRotation(
                          turns: _expandedIds.contains(id) ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: TColor.textSecondary,
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: TColor.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  bodyText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: TColor.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                                if (type != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getNotificationColor(type, false).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      type.replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getNotificationColor(type, false),
                                      ),
                                    ),
                                  ),
                                ],
                                if (n.containsKey('data') && n['data'] is Map<String, dynamic>) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Additional Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: TColor.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...(n['data'] as Map<String, dynamic>).entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${entry.key}: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: TColor.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              entry.value.toString(),
                                              style: TextStyle(
                                                color: TColor.textPrimary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: TColor.textSecondary.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Received $relativeTime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: TColor.textSecondary.withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
