// lib/screen/message/support_home_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'new_ticket_screen.dart';
import 'ticket_chat_screen.dart';

class SupportHomeScreen extends StatefulWidget {
  const SupportHomeScreen({super.key});

  @override
  State<SupportHomeScreen> createState() => _SupportHomeScreenState();
}

class _SupportHomeScreenState extends State<SupportHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  late TabController _tabController;

  // Все тикеты, извлечённые из API
  List<Map<String, dynamic>> _tickets = [];

  // Текущий фильтр статуса: "all", "open", "in_progress", "closed" и т.д.
  String _statusFilter = 'all';

  // Список уникальных статусов для Dropdown
  final List<String> _statusOptions = ['all'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _loading = true;
      _error = null;
      _statusOptions
        ..clear()
        ..add('all');
    });

    try {
      final res = await ApiService.getWithToken('/api/support/tickets');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        final allTickets = data.cast<Map<String, dynamic>>();

        // Собираем уникальные статусы, чтобы заполнить Dropdown
        final statuses = <String>{};
        for (var t in allTickets) {
          final st = (t['status'] as String? ?? 'unknown').toLowerCase();
          statuses.add(st);
        }

        setState(() {
          _statusOptions.addAll(statuses.toList()..sort());
          _tickets = allTickets;
        });
      } else {
        throw 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Возвращает активные тикеты (не закрытые)
  List<Map<String, dynamic>> get _activeTickets {
    return _tickets
        .where((t) =>
    ((t['status'] as String?)?.toLowerCase() ?? '') != 'closed')
        .toList();
  }

  /// Возвращает закрытые тикеты
  List<Map<String, dynamic>> get _closedTickets {
    return _tickets
        .where((t) =>
    ((t['status'] as String?)?.toLowerCase() ?? '') == 'closed')
        .toList();
  }

  /// Возвращает список тикетов с учётом выбранного фильтра
  List<Map<String, dynamic>> _getFilteredTickets(List<Map<String, dynamic>> tickets) {
    if (_statusFilter == 'all') return [...tickets];
    return tickets
        .where((t) =>
    ((t['status'] as String?)?.toLowerCase() ?? '') == _statusFilter)
        .toList();
  }

  /// Форматирует дату создания тикета
  String _formatTicketDate(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Today ${DateFormat('HH:mm').format(dateTime.toLocal())}';
      } else if (difference.inDays == 1) {
        return 'Yesterday ${DateFormat('HH:mm').format(dateTime.toLocal())}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('dd MMM yyyy').format(dateTime.toLocal());
      }
    } catch (e) {
      return '';
    }
  }

  /// Получает цвет статуса тикета
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return TColor.textSecondary;
    }
  }

  /// Получает иконку статуса тикета
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.help_outline;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'resolved':
        return Icons.check_circle_outline;
      case 'closed':
        return Icons.lock_outline;
      default:
        return Icons.help_outline;
    }
  }

  /// Строит карточку одного тикета.
  Widget _buildTicketCard(Map<String, dynamic> ticket, {bool isClosed = false}) {
    final status = (ticket['status'] as String? ?? 'unknown').toLowerCase();
    final hasNew = (ticket['has_new'] as bool?) ?? false;
    final id = ticket['id']?.toString() ?? '?';
    final subject = ticket['subject'] as String? ?? 'No subject';
    final createdAt = ticket['created_at'] as String?;
    final lastMessage = ticket['last_message'] as String?;

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: isClosed ? 1 : 3,
      color: isClosed ? Colors.grey.shade100 : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketChatScreen(
                ticketId: id,
                subject: subject,
                isReadOnly: isClosed,
              ),
            ),
          ).then((_) => _loadTickets());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                children: [
                  // Индикатор новых сообщений
                  if (hasNew && !isClosed)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),

                  // Заголовок тикета
                  Expanded(
                    child: Text(
                      subject,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isClosed
                            ? Colors.grey.shade600
                            : TColor.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Статус
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? Colors.grey.shade200
                          : statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isClosed
                            ? Colors.grey.shade400
                            : statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: isClosed ? Colors.grey.shade600 : statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isClosed ? Colors.grey.shade600 : statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ID тикета и дата
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 14,
                    color: isClosed ? Colors.grey.shade500 : TColor.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ticket #${id.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: 12,
                      color: isClosed ? Colors.grey.shade500 : TColor.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (createdAt != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isClosed ? Colors.grey.shade500 : TColor.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTicketDate(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isClosed ? Colors.grey.shade500 : TColor.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),

              // Последнее сообщение (если есть)
              if (lastMessage != null && lastMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isClosed ? Colors.grey.shade50 : TColor.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: isClosed ? Colors.grey.shade500 : TColor.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: isClosed ? Colors.grey.shade600 : TColor.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Кнопка действия
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isClosed ? 'View History' : 'Open Chat',
                    style: TextStyle(
                      fontSize: 12,
                      color: isClosed ? Colors.grey.shade600 : TColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isClosed ? Icons.history : Icons.arrow_forward_ios,
                    size: 14,
                    color: isClosed ? Colors.grey.shade600 : TColor.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsList(List<Map<String, dynamic>> tickets, {bool isClosed = false}) {
    final filteredTickets = _getFilteredTickets(tickets);

    if (filteredTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isClosed ? Icons.history : Icons.support_agent,
              size: 64,
              color: TColor.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isClosed ? 'No closed tickets' : 'No active tickets',
              style: TextStyle(
                fontSize: 18,
                color: TColor.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isClosed
                  ? 'Your ticket history will appear here'
                  : 'Create a new ticket to get started',
              style: TextStyle(
                color: TColor.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return _buildTicketCard(ticket, isClosed: isClosed);
      },
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
        title: const Text(
          'Support Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TColor.primary),
            onPressed: _loadTickets,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: TColor.primary,
          unselectedLabelColor: TColor.textSecondary,
          indicatorColor: TColor.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.support_agent, size: 18),
                  const SizedBox(width: 8),
                  const Text('Active'),
                  if (_activeTickets.any((t) => (t['has_new'] as bool?) ?? false)) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 18),
                  const SizedBox(width: 8),
                  Text('History (${_closedTickets.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TColor.primary,
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewTicketScreen()),
          );
          if (created == true) {
            _loadTickets();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColor.primary),
            const SizedBox(height: 16),
            Text(
              'Loading tickets...',
              style: TextStyle(color: TColor.textSecondary),
            ),
          ],
        ),
      )
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading tickets',
              style: TextStyle(
                fontSize: 18,
                color: TColor.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: TColor.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTickets,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Фильтр по статусу
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 18,
                  color: TColor.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: TColor.divider),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        isExpanded: true,
                        items: _statusOptions
                            .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s == 'all'
                                ? 'All Status'
                                : s[0].toUpperCase() + s.substring(1),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _statusFilter = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Вкладки с тикетами
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Активные тикеты
                RefreshIndicator(
                  onRefresh: _loadTickets,
                  color: TColor.primary,
                  child: _buildTicketsList(_activeTickets, isClosed: false),
                ),
                // Закрытые тикеты (история)
                RefreshIndicator(
                  onRefresh: _loadTickets,
                  color: TColor.primary,
                  child: _buildTicketsList(_closedTickets, isClosed: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
