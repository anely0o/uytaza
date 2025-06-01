// lib/screen/subscription/subscription_edit_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/login/api_service.dart';
import 'package:uytaza/screen/models/subscription_model.dart';

class SubscriptionEditPage extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionEditPage({super.key, required this.subscription});

  @override
  State<SubscriptionEditPage> createState() => _SubscriptionEditPageState();
}

class _SubscriptionEditPageState extends State<SubscriptionEditPage> {
  late DateTime _start, _end;
  late Set<int> _days;
  bool _loading = false;

  // Полные и краткие названия дней
  final _fullWeek  = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  final _shortWeek = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  @override
  void initState() {
    super.initState();
    _start = widget.subscription.start;
    _end   = widget.subscription.end;
    _days  = widget.subscription.days.toSet();
  }

  void _snack(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg),
          backgroundColor: err ? Colors.red : null),
    );
  }

  Future<void> _update() async {
    setState(() => _loading = true);
    try {
      final body = {
        'start_date'  : _start.toUtc().toIso8601String(),
        'end_date'    : _end.toUtc().toIso8601String(),
        'days_of_week': _days.map((i)=>_fullWeek[i-1]).toList(),
      };
      final res = await ApiService.putWithToken(
        '${ApiRoutes.subs}/${widget.subscription.id}',
        body,
      );
      if (res.statusCode == 200) {
        _snack('Subscription updated');
        Navigator.pop(context, true);
      } else {
        throw 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _snack('Update failed: $e', err: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _extend() async {
    setState(() => _loading = true);

    // 1) вычисляем новую дату окончания +30 дней
    final newEnd = _end.add(const Duration(days: 30));

    // 2) формируем тело с обязательным полем end_date
    final body = {
      'end_date': newEnd.toUtc().toIso8601String(),
    };

    try {
      final res = await ApiService.postWithToken(
        '${ApiRoutes.subs}/extend/${widget.subscription.id}',
        body,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _snack('Subscription extended +30 days');

        setState(() => _end = newEnd);
      } else {
        throw 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _snack('Extend failed: $e', err: true);
    } finally {
      setState(() => _loading = false);
    }
  }


  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel this subscription?'),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('No')),
          TextButton(onPressed: ()=>Navigator.pop(context,true),  child: const Text('Yes')),
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
        _snack('Subscription cancelled');
        Navigator.pop(context, true);
      } else {
        throw 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _snack('Cancel failed: $e', err: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Subscription'),
        backgroundColor: TColor.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
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
            _dateRow('Start', _start, (d)=>setState(()=>_start=d)),
            const SizedBox(height: 10),
            _dateRow('End',   _end,   (d)=>setState(()=>_end=d)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                final sel = _days.contains(i+1);
                return FilterChip(
                  label: Text(_shortWeek[i]),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    if (!sel) _days.add(i+1); else _days.remove(i+1);
                  }),
                  selectedColor: TColor.secondary,
                  labelStyle: TextStyle(color: sel ? Colors.white : Colors.black),
                );
              }),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _extend,
                  icon: const Icon(Icons.date_range),
                  label: const Text('Prolong +30'),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _cancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateRow(String label, DateTime v, ValueChanged<DateTime> onPick) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final p = await showDatePicker(
                context: context,
                initialDate: v,
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (p != null) onPick(p);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(DateFormat('dd.MM.yyyy').format(v)),
            ),
          ),
        ),
      ],
    );
  }
}
