// lib/screen/history/history_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/screen/models/subscription_model.dart';
import '../order/client/order_edit_page.dart';
import '../subscription/subscription_edit_page.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;

  List<Order> _closedOrders = [];
  List<Subscription> _cancelledSubs = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      // 1) все заказы
      final ordersRes = await ApiService.getWithToken('/api/orders/my');
      if (ordersRes.statusCode != 200) throw 'Orders HTTP ${ordersRes.statusCode}';

      final List<dynamic> ordersJson = jsonDecode(ordersRes.body);
      final allOrders = ordersJson.map((e) => Order.fromJson(e)).toList();
      // фильтр: только closed (completed или cancelled)
      _closedOrders = allOrders.where((o) {
        final st = o.status.toLowerCase();
        return st == 'completed' || st == 'cancelled';
      }).toList();

      // 2) все подписки
      final subsRes = await ApiService.getWithToken('/api/subscriptions/my');
      if (subsRes.statusCode != 200) throw 'Subs HTTP ${subsRes.statusCode}';

      final List<dynamic> subsJson = jsonDecode(subsRes.body);
      final allSubs = subsJson.map((e) => Subscription.fromJson(e)).toList();
      // фильтр: только cancelled
      _cancelledSubs = allSubs.where((s) => s.status.toLowerCase() == 'cancelled').toList();

      setState(() {
        _error = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildOrderTile(Order order) {
    final fmt = DateFormat('dd.MM.yyyy, HH:mm');
    final formattedDate = fmt.format(order.scheduledAt);
    final serviceNames = order.serviceIds.join(', ');

    final isCancelled = order.status.toLowerCase() == 'cancelled';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'Services: $serviceNames',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${order.address}'),
            Text('Date: $formattedDate'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCancelled ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status[0].toUpperCase() + order.status.substring(1),
                    style: TextStyle(
                      color: isCancelled ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: TColor.primary),
        onTap: () {
          // Редактировать или просмотреть детали исторического заказа
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderEditPage(orderId: order.id),
            ),
          ).then((_) => _loadHistory());
        },
      ),
    );
  }

  Widget _buildSubscriptionTile(Subscription s) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'Order ${s.orderId.substring(0, 6)}…  •  ${s.status[0].toUpperCase()}${s.status.substring(1)}',
          style: TextStyle(
            color: TColor.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${fmt.format(s.start)} → ${fmt.format(s.end)}',
          style: TextStyle(color: TColor.textSecondary, fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: TColor.primary),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TColor.primary,
          unselectedLabelColor: TColor.textSecondary,
          indicatorColor: TColor.primary,
          tabs: const [
            Tab(text: 'Orders History'),
            Tab(text: 'Subscriptions History'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? Center(
        child: Text(
          _error!,
          style: TextStyle(color: TColor.textSecondary),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          // 1) История заказов
          _closedOrders.isEmpty
              ? Center(
            child: Text(
              'No closed orders.',
              style: TextStyle(color: TColor.textSecondary),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _closedOrders.length,
            itemBuilder: (_, i) =>
                _buildOrderTile(_closedOrders[i]),
          ),

          // 2) История подписок
          _cancelledSubs.isEmpty
              ? Center(
            child: Text(
              'No cancelled subscriptions.',
              style: TextStyle(color: TColor.textSecondary),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _cancelledSubs.length,
            itemBuilder: (_, i) =>
                _buildSubscriptionTile(_cancelledSubs[i]),
          ),
        ],
      )),
    );
  }
}
