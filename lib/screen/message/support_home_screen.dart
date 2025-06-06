// lib/screen/message/support_home_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'new_ticket_screen.dart';
import 'ticket_chat_screen.dart';

class SupportHomeScreen extends StatefulWidget {
  const SupportHomeScreen({super.key});

  @override
  State<SupportHomeScreen> createState() => _SupportHomeScreenState();
}

class _SupportHomeScreenState extends State<SupportHomeScreen> {
  bool _loading = true;
  String? _error;

  // Все тикеты, извлечённые из API
  List<Map<String, dynamic>> _tickets = [];

  // Текущий фильтр статуса: "all", "open", "in_progress", "closed" и т.д.
  String _statusFilter = 'all';

  // Список уникальных статусов для Dropdown
  final List<String> _statusOptions = ['all'];

  @override
  void initState() {
    super.initState();
    _loadTickets();
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

  /// Возвращает список тикетов с учётом выбранного фильтра
  List<Map<String, dynamic>> get _filteredTickets {
    if (_statusFilter == 'all') return [..._tickets];
    return _tickets
        .where((t) =>
    ((t['status'] as String?)?.toLowerCase() ?? '') == _statusFilter)
        .toList();
  }

  /// Сортируем тикеты так: всё, что status != 'closed', идёт впереди,
  /// а status == 'closed' — в конец.
  List<Map<String, dynamic>> get _sortedTickets {
    final list = _filteredTickets;
    list.sort((a, b) {
      final sa = ((a['status'] as String?)?.toLowerCase() ?? 'unknown');
      final sb = ((b['status'] as String?)?.toLowerCase() ?? 'unknown');
      final va = sa == 'closed' ? 1 : 0;
      final vb = sb == 'closed' ? 1 : 0;
      return va.compareTo(vb);
    });
    return list;
  }

  /// Строит карточку одного тикета.
  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = (ticket['status'] as String? ?? 'unknown').toLowerCase();
    final hasNew = (ticket['has_new'] as bool?) ?? false;
    final id = ticket['id']?.toString() ?? '?';
    final subject = ticket['subject'] as String? ?? 'No subject';

    // Фон и стили для закрытых тикетов
    final isClosed = status == 'closed';

    // Если тикет закрыт — фон светло-серый, текст — тёмно-серый
    final cardColor = isClosed ? Colors.grey.shade200 : Colors.white;
    final titleColor =
    isClosed ? Colors.grey.shade600 : TColor.textPrimary;
    final subtitleColor =
    isClosed ? Colors.grey.shade500 : TColor.textSecondary;

    final titleStyle = TextStyle(
      color: titleColor,
      fontWeight: FontWeight.bold,
    );
    final subtitleStyle = TextStyle(
      color: subtitleColor,
      fontSize: 13,
    );

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: isClosed ? 0 : 2,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: hasNew && !isClosed
            ? Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.amber, // желтый индикатор "новое"
            shape: BoxShape.circle,
          ),
        )
            : const SizedBox(width: 12),
        title: Text(
          subject,
          style: titleStyle,
        ),
        subtitle: Text(
          '#$id  ·  ${status[0].toUpperCase()}${status.substring(1)}',
          style: subtitleStyle,
        ),
        trailing: isClosed
            ? null
            : Icon(
          Icons.chevron_right,
          color: TColor.primary,
        ),
        // Если тикет закрыт — onTap = null, иначе — навигация в чат
        onTap: isClosed
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketChatScreen(
                ticketId: id,
                subject: subject,
              ),
            ),
          ).then((_) => _loadTickets());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text('Support Requests'),
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Text(
          _error!,
          style: TextStyle(color: TColor.textSecondary),
        ),
      )
          : Column(
        children: [
          // 1) Дропдаун для фильтра по статусу
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Filter by status:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: TColor.divider),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                    ),
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s[0].toUpperCase() + s.substring(1),
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
              ],
            ),
          ),

          // 2) Общий список тикетов (открытые сверху, закрытые — внизу)
          Expanded(
            child: _sortedTickets.isEmpty
                ? const Center(
              child: Text('No tickets found'),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              itemCount: _sortedTickets.length,
              itemBuilder: (context, index) {
                final ticket = _sortedTickets[index];
                return _buildTicketCard(ticket);
              },
            ),
          ),
        ],
      ),
    );
  }
}
