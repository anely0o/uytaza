import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/models/order_model.dart';

class SubscriptionBuildPage extends StatefulWidget {
  const SubscriptionBuildPage({super.key});

  @override
  State<SubscriptionBuildPage> createState() => _SubscriptionBuildPageState();
}

class _SubscriptionBuildPageState extends State<SubscriptionBuildPage> {
  List<Order> _orders = [];
  String? _selectedOrderId;
  bool _orderPreselected = false;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));

  final _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<int> _selectedDays = {1, 5};

  bool _loading = true, _submitting = false;
  bool _argsHandled = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsHandled) return;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) {
      _selectedOrderId = arg;
      _orderPreselected = true;
    }
    _argsHandled = true;
  }

  Future<void> _loadOrders() async {
    try {
      final r = await ApiService.getWithToken('/api/orders/my');
      if (r.statusCode == 200) {
        _orders = (jsonDecode(r.body) as List)
            .map((e) => Order.fromJson(e))
            .toList();
      } else {
        throw 'HTTP ${r.statusCode}';
      }
    } catch (e) {
      _snack('Failed to load orders: $e', err: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m, {bool err = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(m),
          backgroundColor: err ? TColor.accent : null,
        ),
      );

  Future<void> _createSub() async {
    if (_selectedOrderId == null) {
      _snack('Choose order', err: true);
      return;
    }
    if (_selectedDays.isEmpty) {
      _snack('Select days', err: true);
      return;
    }

    setState(() => _submitting = true);
    final body = {
      'order_id': _selectedOrderId,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate.toUtc().toIso8601String(),
      'days_of_week': _selectedDays.map((i) => _weekDays[i - 1]).toList(),
      'price': _calcPriceForOrder(),
    };
    try {
      final res = await ApiService.postWithToken(ApiRoutes.subs, body);
      if (res.statusCode == 201) {
        _snack('Subscription created!');
        Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
      } else {
        final m = res.body.isNotEmpty ? jsonDecode(res.body) : {};
        throw m['error'] ?? m['message'] ?? 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _snack('Failed: $e', err: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
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
          'New Subscription',
          style: TextStyle(
            color: TColor.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: TColor.primary),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _orderSection(),
                    const SizedBox(height: 20),
                    _periodSection(),
                    const SizedBox(height: 20),
                    _daysSection(),
                  ],
                ),
              ),
            ),
          ),
          _submitBtn(),
        ],
      ),
    );
  }

  Widget _orderSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Based on order',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: TColor.textPrimary)),
      const SizedBox(height: 8),
      _orderPreselected
          ? Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: TColor.divider),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(_orderLabel(_orders.firstWhere(
                (o) => o.id == _selectedOrderId,
            orElse: () => Order.placeholder()))),
      )
          : DropdownButtonFormField<String>(
        value: _selectedOrderId,
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: TColor.divider),
          ),
        ),
        items: _orders
            .map(
              (o) => DropdownMenuItem(
            value: o.id,
            child: Text(
              _orderLabel(o),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: TColor.textPrimary),
            ),
          ),
        )
            .toList(),
        onChanged: (v) => setState(() => _selectedOrderId = v),
        hint: Text(
          'Select order',
          style: TextStyle(color: TColor.textSecondary),
        ),
      ),
    ],
  );

  String _orderLabel(Order o) =>
      '${DateFormat('dd.MM').format(o.scheduledAt)} – ${o.address}';

  Widget _periodSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Period', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: _dateBox('Start', startDate, (d) => setState(() => startDate = d))),
          const SizedBox(width: 10),
          Expanded(child: _dateBox('End', endDate, (d) => setState(() => endDate = d))),
        ],
      ),
    ],
  );

  Widget _dateBox(String label, DateTime v, ValueChanged<DateTime> onPick) =>
      GestureDetector(
        onTap: () async {
          final p = await showDatePicker(
            context: context,
            initialDate: v,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (p != null) onPick(p);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: TColor.divider),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: TColor.textSecondary)),
              const SizedBox(height: 4),
              Text(DateFormat('dd.MM.yyyy').format(v),
                  style: TextStyle(fontSize: 16, color: TColor.textPrimary)),
            ],
          ),
        ),
      );

  Widget _daysSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Days of week', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 6,
        children: List.generate(7, (i) {
          final sel = _selectedDays.contains(i + 1);
          return FilterChip(
            label: Text(
              _weekDays[i],
              style: TextStyle(color: sel ? Colors.white : TColor.textPrimary),
            ),
            selected: sel,
            onSelected: (_) => setState(() {
              if (_selectedDays.contains(i + 1)) {
                _selectedDays.remove(i + 1);
              } else {
                _selectedDays.add(i + 1);
              }
            }),
            selectedColor: TColor.primary,
            checkmarkColor: Colors.white,
            backgroundColor: TColor.background,
          );
        }),
      ),
    ],
  );

  Widget _submitBtn() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: ElevatedButton(
      onPressed: _submitting ? null : _createSub,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: TColor.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _submitting
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
        'Create Subscription',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );

  double _calcPriceForOrder() {
    final order = _orders.firstWhere((o) => o.id == _selectedOrderId, orElse: () => Order.placeholder());
    return order.price ?? 0;
  }
}
