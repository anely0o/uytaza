import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';

import 'cleaner_details_screen.dart';

class CleanerOrdersScreen extends StatefulWidget {
  const CleanerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<CleanerOrdersScreen> createState() => _CleanerOrdersScreenState();
}

class _CleanerOrdersScreenState extends State<CleanerOrdersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];
  String? _error;
  int _currentLevel = 0;
  int _xpTotal = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchGamification();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.getWithToken(ApiRoutes.cleanerOrders);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        // Фильтруем: не показываем completed
        final filtered = list
            .whereType<Map<String, dynamic>>()
            .where((o) =>
        o['status']?.toString().toLowerCase() != 'completed')
            .toList();
        _orders = filtered;
      } else {
        _error = 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchGamification() async {
    try {
      final res =
      await ApiService.getWithToken(ApiRoutes.gamificationStatus);
      if (res.statusCode == 200) {
        final gd = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _currentLevel = (gd['current_level'] as num).toInt();
          _xpTotal = (gd['xp_total'] as num).toInt();
        });
      }
    } catch (_) {}
  }

  Future<void> _refresh() => _fetchOrders();

  @override
  Widget build(BuildContext context) {
    final xpForCurrentLevel = _xpTotal % 100;
    final progress = xpForCurrentLevel / 100.0;

    return Scaffold(
      backgroundColor: TColor.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level $_currentLevel   •   XP '
                  '$xpForCurrentLevel/100'),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: TColor.divider,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _orders.isEmpty
                  ? ListView(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.6,
                ),
                Center(
                  child: Text(
                    'No assigned orders yet.',
                    style: TextStyle(color: TColor.textSecondary),
                  ),
                ),
              ])
                  : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _orders.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 14),
                itemBuilder: (_, i) => _orderCard(_orders[i]),
              ),
            )),
      ]),
    );
  }

  Future<String> _fetchUserName(String userId) async {
    try {
      final res =
      await ApiService.getWithToken('${ApiRoutes.userById}/$userId');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final first = decoded['first_name']?.toString() ?? '';
        final last = decoded['last_name']?.toString() ?? '';
        return (first + ' ' + last).trim();
      }
    } catch (_) {}
    return '';
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final rawId = order['_id']?.toString() ?? order['id']?.toString() ?? '';
    final orderId = rawId;
    final clientId = order['client_id']?.toString() ?? '';
    final cleanerList = (order['cleaner_id'] as List<dynamic>?)
        ?.map((c) => c.toString())
        .toList() ??
        [];
    final address = order['address']?.toString() ?? '—';
    final serviceType = (order['service_type'] as String?)?.isNotEmpty == true
        ? order['service_type']!
        : '—';
    final dateIso = order['date']?.toString() ?? '';
    final dateDt = DateTime.tryParse(dateIso);
    final dateStr = dateDt != null
        ? DateFormat('dd.MM.yyyy, HH:mm').format(dateDt.toLocal())
        : '—';
    final statusRaw = order['status']?.toString() ?? '';
    final statusCapitalized = statusRaw.isNotEmpty
        ? statusRaw[0].toUpperCase() + statusRaw.substring(1)
        : 'Unknown';

    // media preview
    final photos = (order['photo_urls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: TColor.softShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FutureBuilder<String>(
          future: clientId.isNotEmpty ? _fetchUserName(clientId) : Future.value('—'),
          builder: (context, snapshot) {
            final name = snapshot.connectionState == ConnectionState.done &&
                (snapshot.data?.isNotEmpty ?? false)
                ? snapshot.data!
                : (snapshot.connectionState == ConnectionState.waiting
                ? 'Loading…'
                : '—');
            return Row(children: [
              const Icon(Icons.person, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                  child: Text('Client: $name',
                      style: TextStyle(
                          fontSize: 14, color: TColor.textPrimary))),
            ]);
          },
        ),
        const SizedBox(height: 8),
        if (cleanerList.isNotEmpty) ...[
          FutureBuilder<List<String>>(
            future: Future.wait(cleanerList.map((id) => _fetchUserName(id))),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(children: const [
                  Icon(Icons.cleaning_services, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('Loading cleaners…'),
                ]);
              }
              final names = snapshot.data!
                  .where((n) => n.isNotEmpty)
                  .join(', ');
              return Row(children: [
                const Icon(Icons.cleaning_services, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(
                        'Cleaners: ${names.isNotEmpty ? names : '—'}',
                        style: TextStyle(
                            fontSize: 14, color: TColor.textPrimary))),
              ]);
            },
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          const Icon(Icons.location_on, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
              child:
              Text(address,
                  style: TextStyle(
                      fontSize: 14, color: TColor.textPrimary))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.cleaning_services, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
              child:
              Text('Type: $serviceType',
                  style: TextStyle(
                      fontSize: 14, color: TColor.textPrimary))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.access_time, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
              child: Text(dateStr,
                  style:
                  TextStyle(fontSize: 14, color: TColor.textSecondary))),
        ]),
        const SizedBox(height: 8),
        Chip(
            backgroundColor: statusRaw == 'cancelled'
                ? Colors.red[100]
                : Colors.orange[100],
            label: Text(statusCapitalized,
                style: TextStyle(
                    color: statusRaw == 'cancelled'
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),

        // —— Media Preview for non-completed orders (in case photo exists) ——
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    photos[i],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OrderDetailsScreen(orderId: orderId, readOnly: false,),
                ),
              );
              if (changed == true) _fetchOrders();
            },
            child: const Text('Details'),
          ),
        ),
      ]),
    );
  }
}
