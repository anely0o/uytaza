// 1. Главный экран поддержки (список тикетов)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'new_ticket_screen.dart';
import 'ticket_chat_screen.dart';


class SupportHomeScreen extends StatefulWidget {
  const SupportHomeScreen({super.key});

  @override
  State<SupportHomeScreen> createState() => _SupportHomeScreenState();
}

class _SupportHomeScreenState extends State<SupportHomeScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final res = await ApiService.getWithToken('/api/support/tickets');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          _tickets = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        throw 'Failed to load tickets';
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Requests'),
        backgroundColor: TColor.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.primary,
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewTicketScreen()),
          );
          if (created == true) _loadTickets();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _tickets.length,
        itemBuilder: (_, i) {
          final ticket = _tickets[i];
          return ListTile(
            title: Text(ticket['subject'] ?? 'No subject'),
            subtitle: Text("#${ticket['id']} | ${ticket['status'] ?? 'open'}"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketChatScreen(ticketId: ticket['id'].toString(), subject: ticket['subject'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
