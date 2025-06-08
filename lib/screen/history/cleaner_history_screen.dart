import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/order_model.dart';

class CleanerHistoryScreen extends StatefulWidget {
  const CleanerHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CleanerHistoryScreen> createState() => _CleanerHistoryScreenState();
}

class _CleanerHistoryScreenState extends State<CleanerHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<Order> _finishedOrders = [];

  @override
  void initState() {
    super.initState();
    _loadCleanerHistory();
  }

  Future<void> _loadCleanerHistory() async {
    setState(() {
      _loading = true;
      _error = null;
      _finishedOrders = [];
    });
    try {
      final res = await ApiService.getWithToken(ApiRoutes.cleanerOrders);
      if (res.statusCode != 200) throw 'Orders HTTP ${res.statusCode}';
      final List<dynamic> jsonList = jsonDecode(res.body);
      final allOrders = jsonList.map((e) => Order.fromJson(e)).toList();
      _finishedOrders = allOrders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'completed' || s == 'cancelled';
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildOrderTile(Order order) {
    final fmt = DateFormat('dd.MM.yyyy, HH:mm');
    final dateStr = fmt.format(order.scheduledAt);
    final rating = order.rating ?? 0.0;
    final reviews = order.reviews ?? <String>[];
    final photos = order.photoUrls ?? <String>[];
    final isCancelled = order.status.toLowerCase() == 'cancelled';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: $dateStr',
                    style: TextStyle(
                        fontSize: 14,
                        color: TColor.textSecondary)),
                if (isCancelled)
                  Chip(
                    label: Text('Cancelled',
                        style: TextStyle(color: Colors.red[800])),
                    backgroundColor: Colors.red[100],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // —— Photo Preview ——
            if (photos.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
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
              const SizedBox(height: 12),
            ],

            if (!isCancelled) ...[
              Row(children: [
                const Icon(Icons.star,
                    size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(rating.toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 14,
                        color: TColor.textPrimary)),
              ]),
              const SizedBox(height: 12),
              if (reviews.isEmpty)
                Text('No reviews for this order.',
                    style: TextStyle(
                        color: TColor.textSecondary))
              else ...[
                Text('Reviews:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TColor.textPrimary)),
                const SizedBox(height: 6),
                for (var r in reviews)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $r',
                        style: TextStyle(
                            color: TColor.textSecondary)),
                  ),
              ],
            ],
          ],
        ),
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
        title: const Text('Order History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? Center(
          child: Text(_error!,
              style: TextStyle(color: TColor.textSecondary)))
          : RefreshIndicator(
        onRefresh: _loadCleanerHistory,
        child: _finishedOrders.isEmpty
            ? Center(
          child: Text('No completed orders yet.',
              style: TextStyle(color: TColor.textSecondary)),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _finishedOrders.length,
          itemBuilder: (_, i) => _buildOrderTile(_finishedOrders[i]),
        ),
      )),
    );
  }
}