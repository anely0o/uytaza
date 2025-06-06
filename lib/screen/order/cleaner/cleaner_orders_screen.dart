// lib/screen/order/cleaner/cleaner_orders_screen.dart

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

  // Gamification fields
  int _currentLevel = 0;
  int _xpTotal      = 0;

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
        _orders = list.whereType<Map<String, dynamic>>().toList();
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
      final res = await ApiService.getWithToken(ApiRoutes.gamificationStatus);
      if (res.statusCode == 200) {
        final gd = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _currentLevel = (gd['current_level'] as num).toInt();
          _xpTotal      = (gd['xp_total'] as num).toInt();
        });
      }
    } catch (_) {
      // Игнорируем ошибки геймификации
    }
  }

  Future<void> _refresh() => _fetchOrders();

  @override
  Widget build(BuildContext context) {
    // Для прогресс-бара считаем, что 100 XP = 1 уровень
    final xpForCurrentLevel = _xpTotal % 100;
    final progress = xpForCurrentLevel / 100.0;

    return Scaffold(
      backgroundColor: TColor.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
        children: [
          // ── Блок с геймификацией ─────────────────────────
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $_currentLevel   •   XP $xpForCurrentLevel/100',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColor.textPrimary,
                  ),
                ),
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
          // ── Список заказов ─────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _orders.isEmpty
                  ? ListView(
                // обёрнут в ListView для работы RefreshIndicator
                children: [
                  SizedBox(
                    height:
                    MediaQuery.of(context).size.height *
                        0.6,
                  ),
                  Center(
                    child: Text(
                      'You have no assigned orders yet, you can relax.',
                      style: TextStyle(
                        color: TColor.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _orders.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 14),
                itemBuilder: (_, i) =>
                    _orderCard(_orders[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Для данного userId делает GET /api/users/{userId} и возвращает "FirstName LastName".
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
    } catch (_) {
      // Игнорируем ошибки
    }
    return ''; // если что-то пошло не так, возвращаем пустую строку
  }

  Widget _orderCard(Map<String, dynamic> order) {
    // 1) Определяем правильный ID: сначала "_id", иначе "id"
    final rawId = order['_id']?.toString() ?? order['id']?.toString() ?? '';
    final orderId = rawId;

    // 2) Извлекаем client_id и список cleaner_id[]
    final clientId = order['client_id']?.toString() ?? '';
    final cleanerList =
        (order['cleaner_id'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? [];

    // 3) Address
    final address = order['address']?.toString() ?? '—';

    // 4) Service Type
    final serviceType = (order['service_type'] as String?)?.isNotEmpty == true
        ? order['service_type']!
        : '—';

    // 5) Date ("date")
    final dateIso = order['date']?.toString() ?? '';
    final dateDt = DateTime.tryParse(dateIso);
    final dateStr = dateDt != null
        ? DateFormat('dd.MM.yyyy, HH:mm').format(dateDt.toLocal())
        : '—';

    // 6) Status
    final statusRaw = order['status']?.toString() ?? '';
    final statusCapitalized = statusRaw.isNotEmpty
        ? statusRaw[0].toUpperCase() + statusRaw.substring(1)
        : 'Unknown';

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
          // Client name вместо client_id (асинхронно через FutureBuilder)
          FutureBuilder<String>(
            future: clientId.isNotEmpty ? _fetchUserName(clientId) : Future.value('—'),
            builder: (context, snapshot) {
              final name = snapshot.connectionState == ConnectionState.done &&
                  (snapshot.data?.isNotEmpty ?? false)
                  ? snapshot.data!
                  : (snapshot.connectionState == ConnectionState.waiting
                  ? 'Loading…'
                  : '—');
              return Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Client: $name',
                      style: TextStyle(
                        fontSize: 14,
                        color: TColor.textPrimary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),

          // Cleaner names (если есть) вместо cleaner_id[]
          if (cleanerList.isNotEmpty) ...[
            FutureBuilder<List<String>>(
              future: Future.wait(cleanerList.map((id) => _fetchUserName(id))),
              builder: (context, snapshot) {
                Widget child;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  child = Row(
                    children: const [
                      Icon(Icons.cleaning_services, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('Loading cleaners…'),
                    ],
                  );
                } else if (snapshot.hasError || snapshot.data == null) {
                  child = Row(
                    children: [
                      const Icon(Icons.cleaning_services, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Cleaners: —',
                        style: TextStyle(fontSize: 14, color: TColor.textSecondary),
                      ),
                    ],
                  );
                } else {
                  final names = snapshot.data!.where((n) => n.isNotEmpty).join(', ');
                  child = Row(
                    children: [
                      const Icon(Icons.cleaning_services, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Cleaners: ${names.isNotEmpty ? names : '—'}',
                          style: TextStyle(fontSize: 14, color: TColor.textPrimary),
                        ),
                      ),
                    ],
                  );
                }
                return child;
              },
            ),
            const SizedBox(height: 8),
          ],

          // Address
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 14, color: TColor.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Service Type
          Row(
            children: [
              const Icon(Icons.cleaning_services, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Type: $serviceType',
                  style: TextStyle(fontSize: 14, color: TColor.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateStr,
                  style: TextStyle(fontSize: 14, color: TColor.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Status
          Chip(
            backgroundColor: statusRaw == 'finished' ? Colors.green[100] : Colors.orange[100],
            label: Text(
              statusCapitalized,
              style: TextStyle(
                color: statusRaw == 'finished' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Details button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                if (orderId.isEmpty) {
                  _fetchOrders();
                  return;
                }
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(orderId: orderId),
                  ),
                );
                if (changed == true) {
                  _fetchOrders();
                }
              },
              child: const Text('Details'),
            ),
          ),
        ],
      ),
    );
  }
}
