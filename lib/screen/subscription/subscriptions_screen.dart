import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/subscription_model.dart';
import 'subscription_build_page.dart';
import 'subscription_edit_page.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _loading = true;
  String? _error;
  List<Subscription> _allSubs = [];

  String _statusFilter = 'all'; // 'all' or 'active'
  DateTime? _dateFilter;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.getWithToken('/api/subscriptions/my');
      if (r.statusCode == 200) {
        final subs = (jsonDecode(r.body) as List)
            .map((e) => Subscription.fromJson(e))
            .toList();
        if (mounted) {
          setState(() {
            _allSubs = subs;
            _error = null;
            _loading = false;
          });
        }
      } else {
        throw 'HTTP ${r.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Subscription> get _filteredSubs {
    final activeOnly = _allSubs.where((s) => s.status.toLowerCase() != 'cancelled').toList();

    return activeOnly.where((s) {
      final matchesStatus = (_statusFilter == 'all') ||
          (s.status.toLowerCase() != 'cancelled' && _statusFilter == 'active');
      final matchesDate = _dateFilter == null ||
          DateFormat('yyyy-MM-dd').format(s.startDate) ==
              DateFormat('yyyy-MM-dd').format(_dateFilter!);
      return matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubs = _filteredSubs;

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'My Subscriptions',
          style: TextStyle(
            color: TColor.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primary),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionBuildPage()),
          );
          if (result == true) {
            _loadSubscriptions();
          }
        },
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null
            ? Center(
          child: Text(
            _error!,
            style: TextStyle(color: TColor.textSecondary),
          ),
        )
            : Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _statusFilter = val);
                    }
                  },
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: Icon(Icons.date_range, color: TColor.primary),
                  label: Text(
                    _dateFilter == null
                        ? "Start date"
                        : DateFormat('yyyy-MM-dd').format(_dateFilter!),
                    style: TextStyle(color: TColor.primary),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _dateFilter = picked);
                    }
                  },
                ),
                if (_dateFilter != null)
                  IconButton(
                    icon: Icon(Icons.clear, color: TColor.primary),
                    onPressed: () => setState(() => _dateFilter = null),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredSubs.isEmpty
                  ? Center(
                child: Text(
                  'No active subscriptions.',
                  style: TextStyle(
                      fontSize: 16,
                      color: TColor.textSecondary),
                ),
              )
                  : ListView.builder(
                itemCount: filteredSubs.length,
                itemBuilder: (_, i) {
                  final s = filteredSubs[i];
                  final fmt = DateFormat('dd MMM yyyy');
                  final isCancelled =
                      s.status.toLowerCase() == 'cancelled';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin:
                    const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Order ${s.orderId.substring(0, 6)}…  •  ${s.status[0].toUpperCase()}${s.status.substring(1)}',
                        style: TextStyle(
                          color: isCancelled
                              ? TColor.textSecondary
                              .withOpacity(0.7)
                              : TColor.textPrimary,
                          fontWeight: isCancelled
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${fmt.format(s.startDate)} → ${fmt.format(s.endDate)}',
                        style: TextStyle(
                          color: isCancelled
                              ? TColor.textSecondary
                              .withOpacity(0.7)
                              : TColor.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: isCancelled
                            ? TColor.textSecondary
                            : TColor.primary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubscriptionEditPage(
                                subscription: s),
                          ),
                        ).then((_) => _loadSubscriptions());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}
