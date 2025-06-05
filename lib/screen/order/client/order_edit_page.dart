import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/screen/payment/payment_page.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';

import '../../../api/api_routes.dart';

class OrderEditPage extends StatefulWidget {
  final String orderId;
  const OrderEditPage({super.key, required this.orderId});

  @override
  State<OrderEditPage> createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  bool _loading = true;
  bool _saving = false;
  String? _error;

  // Order status and amount (₸)
  String? _status;
  double _amount = 0.0;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final TextEditingController _addrCtl = TextEditingController();
  final TextEditingController _noteCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final res = await ApiService.getWithToken(
        '${ApiRoutes.orders}/${widget.orderId}',
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;

        // 1) Save status
        _status = (data['status'] as String).toLowerCase();

        // 2) Date/time
        // In response you might have either "date" or "scheduled_at" key - check what you have.
        // I assume "date" is used (ISO string).
        final dateStr = (data['date'] as String?) ?? (data['scheduled_at'] as String?);
        if (dateStr != null) {
          _date = DateTime.parse(dateStr).toLocal();
          _time = TimeOfDay.fromDateTime(_date);
        }

        // 3) Address and comment
        _addrCtl.text = data['address'] as String? ?? '';
        _noteCtl.text = data['comment'] as String? ?? '';

        // 4) Order amount:
        //    a) If "total_price" field exists, use it
        if (data.containsKey('total_price')) {
          final tp = data['total_price'];
          if (tp is num) {
            _amount = tp.toDouble();
          } else {
            _amount = double.tryParse(tp.toString()) ?? 0.0;
          }
        }
        //    b) Otherwise, if "price" exists - use it
        else if (data.containsKey('price')) {
          final p = data['price'];
          if (p is num) {
            _amount = p.toDouble();
          } else {
            _amount = double.tryParse(p.toString()) ?? 0.0;
          }
        }

        if (_amount == 0.0 && data.containsKey('service_ids')) {
          final ids = (data['service_ids'] as List).cast<String>();
          double sum = 0.0;
          for (var sid in ids) {
            final svcRes = await ApiService.getWithToken('/api/services/$sid');
            if (svcRes.statusCode == 200) {
              final svcJson = jsonDecode(svcRes.body) as Map<String, dynamic>;
              final priceField = svcJson['price'];
              if (priceField is num) sum += priceField.toDouble();
            }
          }
          _amount = sum;
        }

        if (_amount <= 0.0) {
          // You can comment this line if debug warnings aren't needed:
          debugPrint('Warning: Order ${widget.orderId} has amount = 0');
        }

        _error = null;
      } else {
        _error = 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Extracts user_id from JWT token (payload)
  Future<String?> _extractUserIdFromToken() async {
    final rawToken = await ApiService.getToken();
    if (rawToken == null || rawToken.split('.').length != 3) return null;

    final parts = rawToken.split('.');
    var payloadBase64 = parts[1]
        .replaceAll('-', '+')
        .replaceAll('_', '/'); // URL-safe Base64 → standard Base64
    final normalized = base64.normalize(payloadBase64);
    final decoded = utf8.decode(base64.decode(normalized));
    final Map<String, dynamic> payload = jsonDecode(decoded);

    if (payload.containsKey('user_id')) {
      return payload['user_id'].toString();
    } else if (payload.containsKey('id')) {
      return payload['id'].toString();
    } else if (payload.containsKey('sub')) {
      return payload['sub'].toString();
    }
    return null;
  }

  void _navigateToPayment() async {
    // If amount is zero - don't proceed
    if (_amount <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order amount is zero and cannot be paid.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final extractedUserId = await _extractUserIdFromToken();
    if (extractedUserId == null || extractedUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to extract user_id from token.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amountInt = _amount.toInt();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          entityType: 'order',
          entityId: widget.orderId,
          userId: extractedUserId,
          amount: amountInt,
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final body = {
      'address': _addrCtl.text.trim(),
      'comment': _noteCtl.text.trim(),
      'date': DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ).toUtc().toIso8601String(),
    };

    try {
      final r = await ApiService.putWithToken(
        '${ApiRoutes.orders}/${widget.orderId}',
        body,
      );
      if (r.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        throw 'HTTP ${r.statusCode}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Edit Order',
          style: TextStyle(
            color: TColor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: TColor.primary),
        actions: [
          IconButton(
            onPressed: (_saving || _loading) ? null : _save,
            icon: Icon(Icons.save, color: TColor.primary),
          ),
        ],
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
          : _formContent()),
    );
  }

  Widget _formContent() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        _dateRow(context),
        const SizedBox(height: 10),
        _timeRow(context),
        const SizedBox(height: 20),
        TextField(
          controller: _addrCtl,
          decoration: InputDecoration(
            labelText: 'Address',
            labelStyle: TextStyle(color: TColor.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: TColor.divider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: TColor.primary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _noteCtl,
          decoration: InputDecoration(
            labelText: 'Comment',
            labelStyle: TextStyle(color: TColor.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: TColor.divider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: TColor.primary),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // If order status is "pending", show payment button
        if (_status == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pay for Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _dateRow(BuildContext ctx) => Row(
    children: [
      Text(
        'Date:',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: TColor.textPrimary,
        ),
      ),
      const SizedBox(width: 8),
      TextButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: ctx,
            initialDate: _date,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: Text(
          DateFormat('dd.MM.yyyy').format(_date),
          style: TextStyle(color: TColor.primary),
        ),
      ),
    ],
  );

  Widget _timeRow(BuildContext ctx) => Row(
    children: [
      Text(
        'Time:',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: TColor.textPrimary,
        ),
      ),
      const SizedBox(width: 8),
      TextButton(
        onPressed: () async {
          final picked =
          await showTimePicker(context: ctx, initialTime: _time);
          if (picked != null) setState(() => _time = picked);
        },
        child: Text(
          _time.format(ctx),
          style: TextStyle(color: TColor.primary),
        ),
      ),
    ],
  );
}