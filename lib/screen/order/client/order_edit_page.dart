import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';

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

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final TextEditingController _addrCtl = TextEditingController();
  final TextEditingController _noteCtl = TextEditingController();

  Future<void> _load() async {
    try {
      final res = await ApiService.getWithToken(
        '${ApiRoutes.orders}/${widget.orderId}',
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final order = Order.fromJson(data);

        _date = order.scheduledAt;
        _time = TimeOfDay.fromDateTime(order.scheduledAt);
        _addrCtl.text = order.address;
        _noteCtl.text = order.comment ?? '';
        _error = null;
      } else {
        _error = 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
  void initState() {
    super.initState();
    _load();
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
          final picked = await showTimePicker(
            context: ctx,
            initialTime: _time,
          );
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
