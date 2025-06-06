// lib/screen/subscription/subscription_build_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/screen/models/subscription_model.dart'; // For placeholder usage

class SubscriptionBuildPage extends StatefulWidget {
  const SubscriptionBuildPage({super.key});

  @override
  State<SubscriptionBuildPage> createState() => _SubscriptionBuildPageState();
}

class _SubscriptionBuildPageState extends State<SubscriptionBuildPage> {
  // List of available orders (fetched from /api/orders/my)
  List<Order> _orders = [];
  String? _selectedOrderId;
  bool _orderPreselected = false;

  // Date pickers
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));

  // Weekdays & selected days
  final _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<int> _selectedDays = {1, 5};

  // Frequency options
  final List<String> _frequencies = [
    'weekly',
    'biweekly',
    'triweekly',
    'monthly'
  ];
  String _selectedFrequency = 'weekly';

  // Week-number picker (1..5) – for non-weekly frequencies
  final Set<int> _selectedWeekNumbers = {};

  bool _loading = true;
  bool _submitting = false;
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
      _showSnack('Failed to load orders: $e', err: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: err ? TColor.accent : null,
      ),
    );
  }

  Future<void> _createSubscription() async {
    // 1) Validate order selection
    if (_selectedOrderId == null) {
      _showSnack('Please select an order', err: true);
      return;
    }
    // 2) Validate days of week
    if (_selectedDays.isEmpty) {
      _showSnack('Please select at least one weekday', err: true);
      return;
    }
    // 3) Validate week numbers if frequency != weekly
    if (_selectedFrequency != 'weekly') {
      int requiredCount;
      switch (_selectedFrequency) {
        case 'biweekly':
          requiredCount = 2;
          break;
        case 'triweekly':
          requiredCount = 3;
          break;
        case 'monthly':
          requiredCount = 1;
          break;
        default:
          requiredCount = 0;
      }
      if (_selectedWeekNumbers.length != requiredCount) {
        _showSnack(
          'Please select exactly $requiredCount week number(s)',
          err: true,
        );
        return;
      }
    }

    setState(() => _submitting = true);

    final body = {
      'order_id': _selectedOrderId,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate.toUtc().toIso8601String(),
      'frequency': _selectedFrequency,
      'days_of_week':
      _selectedDays.map((i) => _weekDays[i - 1]).toList(),
      'week_numbers': _selectedFrequency == 'weekly'
          ? <int>[]
          : _selectedWeekNumbers.toList(),
    };

    try {
      final res = await ApiService.postWithToken(
        ApiRoutes.subs,
        body,
      );
      if (res.statusCode == 201) {
        _showSnack('Subscription created!');
        Navigator.pushNamedAndRemoveUntil(
            context, '/main', (route) => false);
      } else {
        final respMap =
        res.body.isNotEmpty ? jsonDecode(res.body) : {};
        throw respMap['error'] ??
            respMap['message'] ??
            'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _showSnack('Failed to create subscription: $e', err: true);
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
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _orderSection(),
                    const SizedBox(height: 20),
                    _periodSection(),
                    const SizedBox(height: 20),
                    _frequencySection(),
                    const SizedBox(height: 20),
                    _daysOfWeekSection(),
                    if (_selectedFrequency != 'weekly') ...[
                      const SizedBox(height: 20),
                      _weekNumbersSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _submitButton(),
        ],
      ),
    );
  }

  Widget _orderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Based on Order',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: TColor.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _orderPreselected
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: TColor.divider),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _orderLabel(
              _orders.firstWhere(
                    (o) => o.id == _selectedOrderId,
                orElse: () => Order.placeholder(),
              ),
            ),
          ),
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
                style:
                TextStyle(color: TColor.textPrimary),
              ),
            ),
          )
              .toList(),
          onChanged: (v) =>
              setState(() => _selectedOrderId = v),
          hint: Text(
            'Select Order',
            style: TextStyle(color: TColor.textSecondary),
          ),
        ),
      ],
    );
  }

  String _orderLabel(Order o) =>
      '${DateFormat('dd.MM').format(o.scheduledAt)} – ${o.address}';

  Widget _periodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Period',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _datePickerBox(
                label: 'Start',
                date: startDate,
                onDatePicked: (d) =>
                    setState(() => startDate = d),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _datePickerBox(
                label: 'End',
                date: endDate,
                onDatePicked: (d) => setState(() => endDate = d),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _datePickerBox({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onDatePicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onDatePicked(picked);
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
            Text(
              label,
              style: TextStyle(fontSize: 12, color: TColor.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd.MM.yyyy').format(date),
              style: TextStyle(fontSize: 16, color: TColor.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedFrequency,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: TColor.divider),
            ),
          ),
          items: _frequencies.map((freq) {
            // Display a user-friendly label
            String label;
            switch (freq) {
              case 'weekly':
                label = 'Weekly';
                break;
              case 'biweekly':
                label = 'Bi-Weekly';
                break;
              case 'triweekly':
                label = 'Tri-Weekly';
                break;
              case 'monthly':
                label = 'Monthly';
                break;
              default:
                label = freq;
            }
            return DropdownMenuItem(
              value: freq,
              child: Text(
                label,
                style: TextStyle(color: TColor.textPrimary),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedFrequency = val;
                _selectedWeekNumbers.clear();
              });
            }
          },
          hint: Text(
            'Select Frequency',
            style: TextStyle(color: TColor.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _daysOfWeekSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Days of Week',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          children: List.generate(7, (i) {
            final selected = _selectedDays.contains(i + 1);
            return FilterChip(
              label: Text(
                _weekDays[i],
                style: TextStyle(
                  color: selected ? Colors.white : TColor.textPrimary,
                ),
              ),
              selected: selected,
              onSelected: (_) => setState(() {
                if (selected) {
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
  }

  Widget _weekNumbersSection() {
    // Determine how many must be selected:
    int requiredCount;
    switch (_selectedFrequency) {
      case 'biweekly':
        requiredCount = 2;
        break;
      case 'triweekly':
        requiredCount = 3;
        break;
      case 'monthly':
        requiredCount = 1;
        break;
      default:
        requiredCount = 0; // not used if weekly
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Week Numbers (${_selectedFrequency == 'monthly' ? 'Choose 1' : 'Choose $requiredCount'})',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          children: List.generate(5, (i) {
            // Week numbers = 1..5
            final weekNum = i + 1;
            final selected = _selectedWeekNumbers.contains(weekNum);
            return FilterChip(
              label: Text(
                '$weekNum',
                style: TextStyle(
                  color: selected ? Colors.white : TColor.textPrimary,
                ),
              ),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  if (selected) {
                    _selectedWeekNumbers.remove(weekNum);
                  } else {
                    // If selecting, ensure we do not exceed requiredCount
                    if (_selectedWeekNumbers.length < requiredCount) {
                      _selectedWeekNumbers.add(weekNum);
                    } else {
                      // If the user tries to pick more than requiredCount, do nothing or show a Snack
                      _showSnack(
                        'You can only select $requiredCount week number(s)',
                        err: true,
                      );
                    }
                  }
                });
              },
              selectedColor: TColor.primary,
              checkmarkColor: Colors.white,
              backgroundColor: TColor.background,
            );
          }),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _submitting ? null : _createSubscription,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: TColor.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: _submitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Create Subscription',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
