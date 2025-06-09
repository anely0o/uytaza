// lib/screen/history/client_history_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/media_model.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/screen/models/subscription_model.dart';
import 'package:uytaza/screen/subscription/subscription_edit_page.dart';

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
  String baseUrl = ApiService.baseUrl;

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

  // Исправленный метод для загрузки фотографий заказа
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

  // Метод для исправления URL хоста
  String _fixHost(String url) {
    return url.replaceFirst('localhost:9000', '$baseUrl:9000');
  }

  Future<void> _pickNewAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    try {
      await ApiService.uploadAvatar(File(img.path));
      // force reload:
      setState(() { /* nothing else */ });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Avatar updated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  // Обновленный метод для отправки рейтинга (только один раз)
  Future<void> _showReviewDialog(Order order) async {
    // Если пользователь уже оставил отзыв, показываем сообщение
    if (order.hasReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reviewed this order')),
      );
      return;
    }

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
          // Обновляем данные после отправки рейтинга
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

  // Обновленный метод для отображения плитки заказа с деталями
  Widget _buildOrderTile(Order order) {
    final fmt = DateFormat('dd.MM.yyyy, HH:mm');
    final dateStr = fmt.format(order.scheduledAt);
    final rating = order.rating ?? 0.0;
    final reviews = order.reviews ?? <String>[];
    final isCancelled = order.status.toLowerCase() == 'cancelled';

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
            // Статус заказа
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 6)}...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColor.textPrimary,
                  ),
                ),
                if (isCancelled)
                  Chip(
                    label: const Text('Cancelled'),
                    backgroundColor: Colors.red[100],
                    labelStyle: TextStyle(color: Colors.red[800]),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                else
                  Chip(
                    label: const Text('Completed'),
                    backgroundColor: Colors.green[100],
                    labelStyle: TextStyle(color: Colors.green[800]),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Детали заказа
            _buildDetailRow(Icons.calendar_today, 'Date', dateStr),
            _buildDetailRow(Icons.location_on, 'Address', order.address),
            if (order.cleaningType.isNotEmpty)
              _buildDetailRow(Icons.cleaning_services, 'Type', order.cleaningType),
            if (order.price != null)
              _buildDetailRow(Icons.attach_money, 'Price', '${order.price!.toStringAsFixed(2)} KZT'),
            if (order.comment != null && order.comment!.isNotEmpty)
              _buildDetailRow(Icons.comment, 'Comment', order.comment!),

            const Divider(height: 24),

            // Рейтинг и отзывы
            if (!isCancelled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  // Кнопка рейтинга только если пользователь еще не оставил отзыв
                  if (!order.hasReviewed)
                    ElevatedButton(
                      onPressed: () => _showReviewDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Rate'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Отзывы
              if (reviews.isNotEmpty) ...[
                Text(
                  'Your Review:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                for (var r in reviews)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• $r',
                      style: TextStyle(color: TColor.textSecondary),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ],

            // Фотографии
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
                    Text(
                      'Photos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для отображения строки с деталями
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: TColor.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: TColor.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: TColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
