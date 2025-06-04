// lib/screen/subscription/subscription_edit_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/models/subscription_model.dart';

class SubscriptionEditPage extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionEditPage({super.key, required this.subscription});

  @override
  State<SubscriptionEditPage> createState() => _SubscriptionEditPageState();
}

class _SubscriptionEditPageState extends State<SubscriptionEditPage> {
  late DateTime _start;
  late DateTime _end;
  late Set<int> _days;
  bool _loading = false;
  String? _error;

  // Полные и краткие названия дней недели:
  final List<String> _fullWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> _shortWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    // Инициализируем локальные значения из переданной subscription:
    _start = widget.subscription.start;
    _end = widget.subscription.end;
    // widget.subscription.days уже приходит как List<int>, например [1,5,7]
    _days = widget.subscription.days.toSet();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? TColor.accent : null,
      ),
    );
  }

  Future<void> _update() async {
    setState(() => _loading = true);
    try {
      // Формируем тело запроса так, чтобы days_of_week были строками:
      final body = {
        'start_date': _start.toUtc().toIso8601String(),
        'end_date': _end.toUtc().toIso8601String(),
        'days_of_week': _days.map((i) => _shortWeek[i - 1]).toList(),
      };

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

  Future<void> _extend() async {
    setState(() => _loading = true);

    // Вычисляем новую дату окончания (+30 дней)
    final newEnd = _end.add(const Duration(days: 30));
    final body = {
      'end_date': newEnd.toUtc().toIso8601String(),
    };

    try {
      final res = await ApiService.postWithToken(
        '${ApiRoutes.subs}/extend/${widget.subscription.id}',
        body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnack('Subscription extended +30 days');
        // Обновляем локальный _end
        setState(() {
          _end = newEnd;
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

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel this subscription?'),
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
            onPressed: _loading ? null : _update,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1) Выбор дней недели
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                final dayIndex = i + 1; // от 1 до 7
                final isSelected = _days.contains(dayIndex);
                return FilterChip(
                  label: Text(
                    _shortWeek[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : TColor.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    if (isSelected) {
                      _days.remove(dayIndex);
                    } else {
                      _days.add(dayIndex);
                    }
                  }),
                  selectedColor: TColor.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: TColor.background,
                );
              }),
            ),
            const SizedBox(height: 30),

            // 2) Кнопки «Prolong +30» и «Cancel»
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _extend,
                  icon: const Icon(Icons.date_range),
                  label: const Text('Prolong +30'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _cancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
