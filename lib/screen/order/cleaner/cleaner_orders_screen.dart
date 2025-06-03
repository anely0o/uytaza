import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';

import 'cleaner_details_screen.dart';

class CleanerOrdersScreen extends StatefulWidget {
  const CleanerOrdersScreen({super.key});

  @override
  State<CleanerOrdersScreen> createState() => _CleanerOrdersScreenState();
}

class _CleanerOrdersScreenState extends State<CleanerOrdersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final res = await ApiService.getWithToken(ApiRoutes.cleanerOrders);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        _orders = list.whereType<Map<String, dynamic>>().toList();
      } else {
        _error = 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() => _fetchOrders();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primary),
        title: Text('My Orders',
            style: TextStyle(
                color: TColor.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _orders.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 14),
          itemBuilder: (_, i) => _orderCard(_orders[i]),
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final id = order['id'].toString();
    final address = order['address'] ?? '';
    final status = order['status'] ?? '';
    final startIso = order['start_time'] ?? order['scheduled_at'];
    final startTime = DateTime.tryParse(startIso ?? '');
    final fmtTime = startTime != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(startTime.toLocal())
        : '';
    final client = order['client'] ?? {};
    final clientName = (client['first_name'] ?? '') +
        ' ' +
        (client['last_name'] ?? '');
    final rating = client['rating']?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: TColor.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(clientName,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColor.textPrimary)),
          const SizedBox(height: 4),
          Row(children: _buildStars(rating)),
          const SizedBox(height: 6),
          Text(address,
              style:
              TextStyle(fontSize: 15, color: TColor.textPrimary)),
          const SizedBox(height: 6),
          Text('Start: $fmtTime',
              style:
              TextStyle(color: TColor.textSecondary, fontSize: 14)),
          const SizedBox(height: 6),
          Chip(
            backgroundColor: status == 'finished'
                ? Colors.green[100]
                : Colors.orange[100],
            label: Text(status,
                style: TextStyle(
                    color: status == 'finished'
                        ? Colors.green
                        : Colors.orange)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: const Text('Details'),
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          OrderDetailsScreen(orderId: id)),
                );
                if (changed == true) _fetchOrders();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    const total = 5;
    int full = rating.floor();
    bool hasHalf = (rating - full) >= 0.5;
    List<Widget> stars = [];
    for (int i = 0; i < full; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (hasHalf)
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
    while (stars.length < total) {
      stars.add(const Icon(Icons.star_border,
          color: Colors.amber, size: 18));
    }
    return stars;
  }
}
