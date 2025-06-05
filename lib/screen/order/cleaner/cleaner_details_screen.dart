import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _order;

  File? _pickedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiService.getWithToken('${ApiRoutes.cleanerOrder}${widget.orderId}');
      if (res.statusCode == 200) {
        _order = jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        _error = 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() => _pickedImage = File(x.path));
  }

  Future<void> _finish() async {
    if (_pickedImage == null) {
      _show('Please upload a photo first');
      return;
    }
    setState(() => _loading = true);

    try {
      final url = '${ApiRoutes.finishOrder}${widget.orderId}/finish';
      final res = await ApiService.postMultipart(
        url,
        fileField: 'photo',
        file: _pickedImage!,
      );
      if (res.statusCode == 200) {
        _show('Order marked as finished');
        // Сообщаем родителю, что статус изменился
        Navigator.pop(context, true);
      } else {
        throw 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _show('Failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFinished = _order?['status'] == 'finished';

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
          : _error != null
          ? Center(child: Text(_error!))
          : _orderContent(),
      floatingActionButton: !isFinished && _pickedImage != null
          ? FloatingActionButton.extended(
        onPressed: _finish,
        backgroundColor: TColor.primary,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Finish'),
      )
          : null,
    );
  }

  Widget _orderContent() {
    final addr = _order?['address'] ?? '';
    final status = _order?['status'] ?? '';
    final extras = List<String>.from(_order?['extras'] ?? []);
    final startIso = _order?['scheduled_at'] ?? _order?['start_time'];
    final startDt = DateTime.tryParse(startIso ?? '');
    final startFmt = startDt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(startDt.toLocal())
        : '';

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoRow('Address', addr),
          const SizedBox(height: 8),
          _infoRow('Start', startFmt),
          const SizedBox(height: 8),
          _infoRow('Status', status),
          const SizedBox(height: 18),
          Text(
            'Extras',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: TColor.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: extras
                .map((e) => Chip(
              label: Text(e),
              backgroundColor: TColor.primary.withOpacity(.1),
              labelStyle: TextStyle(
                color: TColor.textPrimary,
                fontSize: 12,
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 24),
          _pickedImage == null ? _uploadPlaceholder() : _imagePreview(),
        ],
      ),
    );
  }

  Widget _uploadPlaceholder() => GestureDetector(
    onTap: _pickImage,
    child: Container(
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(color: TColor.primary),
        borderRadius: BorderRadius.circular(16),
        color: TColor.primary.withOpacity(.05),
      ),
      child: Center(
        child: Text(
          'Tap to upload photo',
          style: TextStyle(
            color: TColor.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );

  Widget _imagePreview() => Stack(children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        _pickedImage!,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      ),
    ),
    Positioned(
      top: 8,
      right: 8,
      child: InkWell(
        onTap: () => setState(() => _pickedImage = null),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    ),
  ]);

  Widget _infoRow(String key, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$key: ',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: TColor.textPrimary,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: TColor.textSecondary,
          ),
        ),
      ),
    ],
  );

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
