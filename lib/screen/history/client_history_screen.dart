
/// lib/screen/history/client_history_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/screen/models/subscription_model.dart';
import 'package:uytaza/screen/order/client/order_edit_page.dart';
import 'package:uytaza/screen/subscription/subscription_edit_page.dart';

/// Screen for client: tabs for closed orders and cancelled subscriptions
class ClientHistoryScreen extends StatefulWidget {
  const ClientHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;
  List<Order> _orders = [];
  List<Subscription> _cancelledSubs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClientHistory();
  }

  Future<void> _loadClientHistory() async {
    setState(() {
      _loading = true;
      _error = null;
      _orders = [];
      _cancelledSubs = [];
    });

    try {
      // Orders: completed or cancelled
      final ordersRes = await ApiService.getWithToken(ApiRoutes.myOrders);
      if (ordersRes.statusCode != 200) throw 'Orders HTTP ${ordersRes.statusCode}';
      final List<dynamic> ordersJson = jsonDecode(ordersRes.body);
      final allOrders = ordersJson.map((e) => Order.fromJson(e)).toList();
      _orders = allOrders.where((o) {
        final st = o.status.toLowerCase();
        return st == 'completed' || st == 'cancelled';
      }).toList();

      // Subscriptions: only cancelled
      final subsRes = await ApiService.getWithToken('${ApiRoutes.subs}/my');
      if (subsRes.statusCode != 200) throw 'Subs HTTP ${subsRes.statusCode}';
      final List<dynamic> subsJson = jsonDecode(subsRes.body);
      final allSubs = subsJson.map((e) => Subscription.fromJson(e)).toList();
      _cancelledSubs = allSubs.where((s) => s.status.toLowerCase() == 'cancelled').toList();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildOrderTile(Order order) {
    final fmt = DateFormat('dd.MM.yyyy, HH:mm');
    final dateStr = fmt.format(order.scheduledAt);
    final rating = order.rating ?? 0.0;
    final reviews = order.reviews ?? <String>[];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $dateStr', style: TextStyle(fontSize: 14, color: TColor.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 14, color: TColor.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              Text('No reviews for this order.', style: TextStyle(color: TColor.textSecondary))
            else ...[
              Text('Reviews:', style: TextStyle(fontWeight: FontWeight.bold, color: TColor.textPrimary)),
              const SizedBox(height: 6),
              for (var r in reviews)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $r', style: TextStyle(color: TColor.textSecondary)),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTile(Subscription s) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('Order ${s.orderId.substring(0, 6)}…  •  ${s.status[0].toUpperCase()}${s.status.substring(1)}',
            style: TextStyle(color: TColor.textSecondary, fontWeight: FontWeight.w600)),
        subtitle: Text('${fmt.format(s.startDate)} → ${fmt.format(s.endDate)}', style: TextStyle(color: TColor.textSecondary, fontSize: 13)),
        trailing: Icon(Icons.chevron_right, color: TColor.primary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SubscriptionEditPage(subscription: s)),
          ).then((_) => _loadClientHistory());
        },
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
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TColor.primary,
          unselectedLabelColor: TColor.textSecondary,
          indicatorColor: TColor.primary,
          tabs: const [Tab(text: 'Orders'), Tab(text: 'Subscriptions')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? Center(child: Text(_error!, style: TextStyle(color: TColor.textSecondary)))
          : TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _loadClientHistory,
            child: _orders.isEmpty
                ? Center(child: Text('No closed orders.', style: TextStyle(color: TColor.textSecondary)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _orders.length,
              itemBuilder: (_, i) => _buildOrderTile(_orders[i]),
            ),
          ),
          RefreshIndicator(
            onRefresh: _loadClientHistory,
            child: _cancelledSubs.isEmpty
                ? Center(child: Text('No cancelled subscriptions.', style: TextStyle(color: TColor.textSecondary)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _cancelledSubs.length,
              itemBuilder: (_, i) => _buildSubscriptionTile(_cancelledSubs[i]),
            ),
          ),
        ],
      )),
    );
  }
}
