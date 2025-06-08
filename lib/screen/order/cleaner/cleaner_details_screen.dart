// lib/screen/order/OrderDetailsScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';

import '../../../media/upload_photo_screen.dart';
// добавим экран загрузки фото


class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({Key? key, required this.orderId, required bool readOnly}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _order;
  String? _clientName;
  List<String> _cleanerNames = [];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
      _order = null;
      _clientName = null;
      _cleanerNames = [];
    });
    try {
      final res = await ApiService.getWithToken(
        '${ApiRoutes.cleanerOrder}/${widget.orderId}',
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          _order = decoded;
        } else {
          throw 'Invalid server response format';
        }
      } else {
        throw 'HTTP ${res.statusCode}';
      }

      final clientId = _order!['client_id']?.toString();
      final cleaners = (_order!['cleaner_id'] as List<dynamic>?)
          ?.map((c) => c.toString())
          .toList() ??
          [];

      final futures = <Future>[];
      if (clientId != null && clientId.isNotEmpty) {
        futures.add(_fetchUserName(clientId).then((name) {
          _clientName = name;
        }));
      }
      for (final cId in cleaners) {
        futures.add(_fetchUserName(cId).then((name) {
          if (name.isNotEmpty) _cleanerNames.add(name);
        }));
      }
      await Future.wait(futures);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final statusRaw = (_order?['status'] as String?)?.toLowerCase() ?? '';
    final statusCapitalized = statusRaw.isNotEmpty
        ? statusRaw[0].toUpperCase() + statusRaw.substring(1)
        : '—';

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
        title: Text(
          'Order #${widget.orderId}',
          style: TextStyle(
            color: TColor.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? Center(child: Text(_error!))
          : _buildDetailsCard(statusCapitalized)),
    );
  }

  Widget _buildDetailsCard(String statusCapitalized) {
    final address = _order?['address']?.toString() ?? '—';
    final serviceType = (_order?['service_type'] as String?)?.isNotEmpty == true
        ? _order!['service_type']!
        : '—';
    final dateIso = _order?['date']?.toString();
    String dateFmt = '—';
    if (dateIso != null) {
      final dateDt = DateTime.tryParse(dateIso);
      if (dateDt != null) {
        dateFmt = DateFormat('dd.MM.yyyy, HH:mm')
            .format(dateDt.toLocal());
      }
    }
    final comment = _order?['comment']?.toString() ?? '—';
    final createdIso = _order?['created_at']?.toString();
    String createdFmt = '—';
    if (createdIso != null) {
      final createdDt = DateTime.tryParse(createdIso);
      if (createdDt != null) {
        createdFmt =
            DateFormat('dd.MM.yyyy, HH:mm').format(createdDt.toLocal());
      }
    }
    final serviceDetailsList =
        (_order?['service_details'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
            [];

    // Из photo_urls
    final photos =
        (_order?['photo_urls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: TColor.softShadow,
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _infoRow('Client', _clientName ?? '—'),
            const SizedBox(height: 8),
            if (_cleanerNames.isNotEmpty) ...[
              _infoRow('Cleaner(s)', _cleanerNames.join(', ')),
              const SizedBox(height: 8),
            ],
            _infoRow('Address', address),
            const SizedBox(height: 8),
            _infoRow('Service Type', serviceType),
            const SizedBox(height: 8),
            _infoRow('Scheduled at', dateFmt),
            const SizedBox(height: 8),
            _infoRow('Status', statusCapitalized),
            const SizedBox(height: 8),
            _infoRow('Comment', comment),
            const SizedBox(height: 8),
            _infoRow('Created at', createdFmt),

            // —— Photo Report Preview ——
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Photo Report'),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        photos[i],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            if (serviceDetailsList.isNotEmpty) ...[
              _sectionTitle('Service Details'),
              const SizedBox(height: 12),
              ...serviceDetailsList.map((sd) {
                final name = sd['name']?.toString() ?? '—';
                final price = sd['price'] is num
                    ? (sd['price'] as num).toString()
                    : '—';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(name,
                          style: TextStyle(
                              fontSize: 14,
                              color: TColor.textPrimary))),
                      Text('$price ₸',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: TColor.textPrimary)),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              const Divider(),
            ],

            const SizedBox(height: 20),
            _buildFinishSection(statusCapitalized),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishSection(String statusCapitalized) {
    final iscompleted = statusCapitalized.toLowerCase() == 'completed';
    return iscompleted
        ? Center(
      child: Text('This order is already completed.',
          style:
          TextStyle(color: TColor.textSecondary)),
    )
        : Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          // Переходим на UploadPhotoScreen после mark-as-completed
          final uploaded = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  UploadPhotoScreen(orderId: widget.orderId),
            ),
          );
          if (uploaded == true) {
            _loadOrder();
          }
        },
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Mark as completed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.primary,
          padding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: TColor.textPrimary));

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: ',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TColor.textPrimary,
              fontSize: 14)),
      Expanded(
          child: Text(value,
              style:
              TextStyle(fontSize: 14, color: TColor.textSecondary))),
    ]),
  );
}
