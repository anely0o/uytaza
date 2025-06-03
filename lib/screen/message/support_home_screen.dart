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

  // All tickets fetched from the API
  List<Map<String, dynamic>> _tickets = [];

  // Current filter: "all", "open", "in_progress", "closed", etc.
  String _statusFilter = 'all';

  // List of distinct statuses we've seen
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
      _statusOptions.clear();
      _statusOptions.add('all');
    });

    try {
      final res = await ApiService.getWithToken('/api/support/tickets');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        final allTickets = data.cast<Map<String, dynamic>>();

        // Build a list of unique statuses
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

  List<Map<String, dynamic>> get _filteredTickets {
    if (_statusFilter == 'all') return _tickets;
    return _tickets
        .where((t) => (t['status'] as String? ?? '').toLowerCase() == _statusFilter)
        .toList();
  }

  // Build a Card‐style ticket tile, similar to OrdersScreen
  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = (ticket['status'] as String? ?? 'unknown').toLowerCase();
    final hasNew = (ticket['has_new'] as bool?) ?? false;
    final id = ticket['id']?.toString() ?? '?';
    final subject = ticket['subject'] as String? ?? 'No subject';

    final titleStyle = TextStyle(
      color: TColor.textPrimary,
      fontWeight: FontWeight.bold,
    );
    final subtitleStyle = TextStyle(
      color: TColor.textSecondary,
      fontSize: 13,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: hasNew
            ? Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.amber, // yellow dot
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
        trailing: Icon(
          Icons.chevron_right,
          color: TColor.primary,
        ),
        onTap: () {
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
          // 1) Status filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        borderSide: BorderSide(color: TColor.divider),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

          // 2) “Open Tickets” section
          if (_filteredTickets.where((t) => (t['status'] as String?)?.toLowerCase() != 'closed').isNotEmpty) ...[

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filteredTickets.length,
                itemBuilder: (context, index) {
                  final ticket = _filteredTickets.where(
                        (t) => (t['status'] as String?)?.toLowerCase() != 'closed',
                  ).toList()[index];
                  return _buildTicketCard(ticket);
                },
              ),
            ),
          ],

          // 3) “Closed Tickets” section
          if (_filteredTickets.where((t) => (t['status'] as String?)?.toLowerCase() == 'closed').isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Closed Tickets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filteredTickets.length,
                itemBuilder: (context, index) {
                  final ticket = _filteredTickets.where(
                        (t) => (t['status'] as String?)?.toLowerCase() == 'closed',
                  ).toList()[index];
                  return _buildTicketCard(ticket);
                },
              ),
            ),
          ],

          // 4) If no tickets at all:
          if (_filteredTickets.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No tickets found'),
              ),
            ),
        ],
      ),
    );
  }
}
