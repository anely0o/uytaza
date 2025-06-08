// lib/screen/history/client_history_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/screen/models/subscription_model.dart';
import 'package:uytaza/screen/order/client/order_edit_page.dart';
import 'package:uytaza/screen/subscription/subscription_edit_page.dart';

import '../order/cleaner/cleaner_details_screen.dart';

class ClientHistoryScreen extends StatefulWidget {
  const ClientHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen>
    with SingleTickerProviderStateMixin {
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
      final ordersRes = await ApiService.getWithToken(ApiRoutes.myOrders);
      if (ordersRes.statusCode != 200) {
        throw 'Orders HTTP ${ordersRes.statusCode}';
      }
      final List<dynamic> ordersJson = jsonDecode(ordersRes.body);
      final allOrders = ordersJson.map((e) => Order.fromJson(e)).toList();
      _orders = allOrders
          .where((o) {
        final st = o.status.toLowerCase();
        return st == 'completed' || st == 'cancelled';
      }).toList();

      final subsRes = await ApiService.getWithToken('${ApiRoutes.subs}/my');
      if (subsRes.statusCode != 200) {
        throw 'Subs HTTP ${subsRes.statusCode}';
      }
      final List<dynamic> subsJson = jsonDecode(subsRes.body);
      final allSubs = subsJson.map((e) => Subscription.fromJson(e)).toList();
      _cancelledSubs = allSubs
          .where((s) => s.status.toLowerCase() == 'cancelled')
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<List<String>> _loadPhotosForOrder(String orderId) async {
    try {
      final res = await ApiService.getWithToken('${ApiRoutes.mediaReports}/$orderId');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data
            .where((e) => e['URL'] != null)
            .map<String>((e) => e['URL'].toString())
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load photos for order $orderId: $e');
    }
    return [];
  }

  Future<void> _showReviewDialog(Order order) async {
    int rating = order.rating?.round() ?? 5;
    final commentCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Please rate the cleaning'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(builder: (c, setSt) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: TColor.accent,
                    ),
                    onPressed: () => setSt(() => rating = i + 1),
                  );
                }),
              );
            }),
            TextField(
              controller: commentCtl,
              decoration: const InputDecoration(
                labelText: 'Comment',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        final body = {
          'rating': rating,
          'comment': commentCtl.text.trim(),
        };
        final resp = await ApiService.postWithToken(
          '${ApiRoutes.orders}/${order.id}/review',
          body,
        );
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thank you for your feedback!')),
          );
          await _loadClientHistory();
        } else {
          throw 'HTTP ${resp.statusCode}';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  Widget _buildOrderTile(Order order) {
    final fmt = DateFormat('dd.MM.yyyy, HH:mm');
    final dateStr = fmt.format(order.scheduledAt);
    final rating = order.rating ?? 0.0;
    final reviews = order.reviews ?? <String>[];

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $dateStr',
                style: TextStyle(
                    fontSize: 14, color: TColor.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(rating.toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 14, color: TColor.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () => _showReviewDialog(order),
                child: Text(order.hasReviewed ? 'Edit Review' : 'Rate'),
              ),
            ),
            Text('Reviews',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.textPrimary)),
            const SizedBox(height: 6),
            if (reviews.isEmpty)
              Text('No comments.',
                  style: TextStyle(color: TColor.textSecondary))
            else
              for (var r in reviews)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $r',
                      style: TextStyle(color: TColor.textSecondary)),
                ),
            FutureBuilder<List<String>>(
              future: _loadPhotosForOrder(order.id),
              builder: (context, snapshot) {
                final photos = snapshot.data ?? [];
                if (photos.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Photos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColor.textPrimary)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photos[i],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(
                        orderId: order.id,
                        readOnly: true,
                      ),
                    ),
                  );
                },
                child: Text(
                  'View Details',
                  style: TextStyle(color: TColor.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTile(Subscription s) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'Order ${s.orderId.substring(0, 6)}…  •  '
              '${s.status[0].toUpperCase()}${s.status.substring(1)}',
          style: TextStyle(
              color: TColor.textSecondary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${fmt.format(s.startDate)} → ${fmt.format(s.endDate)}',
          style: TextStyle(color: TColor.textSecondary, fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: TColor.primary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    SubscriptionEditPage(subscription: s)),
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
        title: const Text('History',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
          ? Center(
        child: Text(_error!,
            style: TextStyle(color: TColor.textSecondary)),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _loadClientHistory,
            child: _orders.isEmpty
                ? Center(
              child: Text('No closed orders.',
                  style: TextStyle(
                      color: TColor.textSecondary)),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(vertical: 12),
              itemCount: _orders.length,
              itemBuilder: (_, i) =>
                  _buildOrderTile(_orders[i]),
            ),
          ),
          RefreshIndicator(
            onRefresh: _loadClientHistory,
            child: _cancelledSubs.isEmpty
                ? Center(
              child: Text('No cancelled subscriptions.',
                  style: TextStyle(
                      color: TColor.textSecondary)),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(vertical: 12),
              itemCount: _cancelledSubs.length,
              itemBuilder: (_, i) =>
                  _buildSubscriptionTile(
                      _cancelledSubs[i]),
            ),
          ),
        ],
      )),
    );
  }
}
