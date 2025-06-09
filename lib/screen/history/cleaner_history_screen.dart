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

  // Метод для исправления URL хоста
  String _fixHost(String url) {
    return url.replaceFirst('localhost:9000', '172.20.10.5:9000');
  }

  // Метод для загрузки фотографий заказа
  Future<List<String>> _loadPhotosForOrder(String orderId) async {
    try {
      final mediaList = await ApiService.getMediaByOrder(orderId);

      // Фильтруем медиа по типу "report" и orderId
      final reportPhotos = mediaList
          .where((media) => media.URL.isNotEmpty)
          .map((media) => _fixHost(media.URL))
          .toList();

      return reportPhotos;
    } catch (e) {
      debugPrint('Failed to load photos for order $orderId: $e');
      return [];
    }
  }

  // Метод для отображения фото на весь экран
  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTile(Order order) {
    final fmt = DateFormat('dd.MM.yyyy, HH:mm');
    final dateStr = fmt.format(order.scheduledAt);
    final rating = order.rating ?? 0.0;
    final reviews = order.reviews ?? <String>[];
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
            FutureBuilder<List<String>>(
              future: _loadPhotosForOrder(order.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)
                      ),
                    ),
                  );
                }

                final photos = snapshot.data ?? [];
                if (photos.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _showFullScreenImage(photos[i]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              photos[i],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),

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
