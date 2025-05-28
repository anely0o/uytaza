import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/screen/login/api_service.dart';

class OrderEditPage extends StatefulWidget {
  final Order order;
  const OrderEditPage({super.key, required this.order});

  @override
  State<OrderEditPage> createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  late DateTime _date;
  late TimeOfDay _time;
  late TextEditingController _addrCtl;
  late TextEditingController _noteCtl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date   = widget.order.scheduledAt;
    _time   = TimeOfDay.fromDateTime(widget.order.scheduledAt);
    _addrCtl= TextEditingController(text: widget.order.address);
    _noteCtl= TextEditingController(text: widget.order.comment ?? '');
  }

  DateTime _combine() => DateTime(
      _date.year,_date.month,_date.day,_time.hour,_time.minute);

  Future<void> _save() async {
    setState(() => _saving = true);
    final body = {
      'address': _addrCtl.text.trim(),
      'comment': _noteCtl.text.trim(),
      'date'   : _combine().toUtc().toIso8601String(),
    };
    try {
      final r = await ApiService.putWithToken(
          '${ApiRoutes.orders}/${widget.order.id}', body);
      if (r.statusCode == 200) Navigator.pop(context);
      else throw 'HTTP ${r.statusCode}';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
        backgroundColor: TColor.primary,
        actions: [
          IconButton(onPressed: _saving?null:_save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _dateRow(context),
          const SizedBox(height:10),
          _timeRow(context),
          const SizedBox(height:20),
          TextField(
            controller: _addrCtl,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const SizedBox(height:10),
          TextField(
            controller: _noteCtl,
            decoration: const InputDecoration(labelText: 'Comment'),
            maxLines: 3,
          ),
        ]),
      ),
    );
  }

  Widget _dateRow(BuildContext ctx) => Row(
    children:[
      const Text('Date:', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width:8),
      TextButton(
        onPressed: () async {
          final p = await showDatePicker(
              context: ctx,
              initialDate: _date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days:365)));
          if (p!=null) setState(()=>_date=p);
        },
        child: Text(DateFormat('dd.MM.yyyy').format(_date)),
      ),
    ],
  );

  Widget _timeRow(BuildContext ctx) => Row(
    children:[
      const Text('Time:', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width:8),
      TextButton(
        onPressed: () async {
          final t = await showTimePicker(context: ctx, initialTime: _time);
          if (t!=null) setState(()=>_time=t);
        },
        child: Text(_time.format(ctx)),
      ),
    ],
  );
}
