// lib/screen/subscription/subscription_edit_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/models/subscription_model.dart';

class SubscriptionEditPage extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionEditPage({super.key, required this.subscription});

  @override
  State<SubscriptionEditPage> createState() => _SubscriptionEditPageState();
}

class _SubscriptionEditPageState extends State<SubscriptionEditPage> {
  // Period
  late DateTime _startDate;
  late DateTime _endDate;

  // Frequency options
  final List<String> _frequencies = [
    'weekly',
    'biweekly',
    'triweekly',
    'monthly'
  ];
  late String _selectedFrequency;

  // Weekdays (1..7)
  final List<String> _shortWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  late Set<int> _selectedDays;

  // Week numbers (1..5) – used when frequency ≠ weekly
  late Set<int> _selectedWeekNumbers;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initialize from existing subscription:
    final sched = widget.subscription.schedule;
    _startDate = widget.subscription.startDate;
    _endDate = widget.subscription.endDate;
    _selectedFrequency = sched.frequency.toLowerCase();
    _selectedDays = sched.daysOfWeek
        .map((d) => _shortWeek.indexOf(d))
        .where((idx) => idx >= 0 && idx < 7)
        .map((idx) => idx + 1)
        .toSet();
    _selectedWeekNumbers = Set<int>.from(sched.weekNumbers);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? TColor.accent : null,
      ),
    );
  }

  Future<void> _updateSubscription() async {
    if (_selectedDays.isEmpty) {
      _showSnack('Please select at least one weekday', isError: true);
      return;
    }
    if (_selectedFrequency != 'weekly') {
      int required;
      switch (_selectedFrequency) {
        case 'biweekly':
          required = 2;
          break;
        case 'triweekly':
          required = 3;
          break;
        case 'monthly':
          required = 1;
          break;
        default:
          required = 0;
      }
      if (_selectedWeekNumbers.length != required) {
        _showSnack('Please select exactly $required week number(s)',
            isError: true);
        return;
      }
    }

    setState(() => _loading = true);

    final body = {
      'start_date': _startDate.toUtc().toIso8601String(),
      'end_date': _endDate.toUtc().toIso8601String(),
      'frequency': _selectedFrequency,
      'days_of_week':
      _selectedDays.map((i) => _shortWeek[i - 1]).toList(),
      'week_numbers': _selectedFrequency == 'weekly'
          ? <int>[]
          : _selectedWeekNumbers.toList(),
    };

    try {
      final res = await ApiService.putWithToken(
        '${ApiRoutes.subs}/${widget.subscription.id}',
        body,
      );
      if (res.statusCode == 200) {
        _showSnack('Subscription updated');
        Navigator.pop(context, true);
      } else {
        final map = res.body.isNotEmpty
            ? jsonDecode(res.body)
            : {'error': 'HTTP ${res.statusCode}'};
        throw map['error'] ?? 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _showSnack('Update failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _extendSubscription() async {
    setState(() => _loading = true);

    final newEnd = _endDate.add(const Duration(days: 30));
    final body = {'end_date': newEnd.toUtc().toIso8601String()};

    try {
      final res = await ApiService.postWithToken(
        '${ApiRoutes.subs}/extend/${widget.subscription.id}',
        body,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnack('Extended +30 days');
        setState(() {
          _endDate = newEnd;
        });
      } else {
        final map = res.body.isNotEmpty
            ? jsonDecode(res.body)
            : {'error': 'HTTP ${res.statusCode}'};
        throw map['error'] ?? 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _showSnack('Extend failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancelSubscription() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content:
        const Text('Are you sure you want to cancel this subscription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      final res = await ApiService.deleteWithToken(
        '${ApiRoutes.subs}/${widget.subscription.id}',
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        _showSnack('Subscription cancelled');
        Navigator.pop(context, true);
      } else {
        throw 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _showSnack('Cancel failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
        title: Text(
          'Edit Subscription',
          style: TextStyle(
            color: TColor.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: TColor.primary,
            onPressed: _loading ? null : _updateSubscription,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _periodSection(),
            const SizedBox(height: 20),
            _frequencySection(),
            const SizedBox(height: 20),
            _daysOfWeekSection(),
            if (_selectedFrequency != 'weekly') ...[
              const SizedBox(height: 20),
              _weekNumbersSection(),
            ],
            const SizedBox(height: 30),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

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
                date: _startDate,
                onDatePicked: (d) => setState(() => _startDate = d),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _datePickerBox(
                label: 'End',
                date: _endDate,
                onDatePicked: (d) => setState(() => _endDate = d),
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
              child: Text(label, style: TextStyle(color: TColor.textPrimary)),
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
            final dayIndex = i + 1;
            final selected = _selectedDays.contains(dayIndex);
            return FilterChip(
              label: Text(
                _shortWeek[i],
                style: TextStyle(
                  color: selected ? Colors.white : TColor.textPrimary,
                ),
              ),
              selected: selected,
              onSelected: (_) => setState(() {
                if (selected) {
                  _selectedDays.remove(dayIndex);
                } else {
                  _selectedDays.add(dayIndex);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedFrequency == 'monthly'
              ? 'Week Number (select 1)'
              : 'Week Numbers (select $requiredCount)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          children: List.generate(5, (i) {
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
                    if (_selectedWeekNumbers.length < requiredCount) {
                      _selectedWeekNumbers.add(weekNum);
                    } else {
                      _showSnack(
                        'You can only select $requiredCount week number(s)',
                        isError: true,
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

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _loading ? null : _extendSubscription,
          icon: const Icon(Icons.date_range),
          label: const Text('Extend +30'),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColor.primary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _loading ? null : _cancelSubscription,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel'),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColor.accent,
          ),
        ),
      ],
    );
  }
}
