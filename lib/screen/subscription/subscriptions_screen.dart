import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/models/subscription_model.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _loading = true;
  String? _error;
  var _subs = <Subscription>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await ApiService.getWithToken('/api/subscriptions/my');
      if (r.statusCode == 200) {
        final subs = (jsonDecode(r.body) as List)
            .map((e) => Subscription.fromJson(e))
            .toList();

        subs.sort((a, b) {
          if (a.status == 'cancelled' && b.status != 'cancelled') return 1;
          if (a.status != 'cancelled' && b.status == 'cancelled') return -1;
          return 0;
        });

        if (mounted) {
          setState(() {
            _subs = subs;
            _error = null;
          });
        }
      } else {
        throw 'HTTP ${r.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscriptions'),
          backgroundColor: TColor.primary),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _subs.isEmpty
          ? const Center(child: Text('No subscriptions'))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _subs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final s = _subs[i];
          final fmt = DateFormat('dd.MM.yy');

          final isCancelled = s.status.toLowerCase() == 'cancelled';
          final textStyle = TextStyle(
            color: isCancelled ? TColor.secondaryText.withOpacity(0.5) : TColor.primaryText,
            fontWeight: isCancelled ? FontWeight.normal : FontWeight.w600,
          );

          return ListTile(
            tileColor: isCancelled ? Colors.grey.shade100 : null,
            title: Text(
              'Order ${s.orderId.substring(0, 6)}…  •  ${s.status}',
              style: textStyle,
            ),
            subtitle: Text(
              '${fmt.format(s.start)} → ${fmt.format(s.end)}',
              style: textStyle.copyWith(fontSize: 13),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isCancelled ? Colors.grey : TColor.primaryText,
            ),
            onTap: () {
              if (!isCancelled) {
                Navigator.pushNamed(context, '/subs/edit', arguments: s)
                    .then((_) => _load());
              }
            },
          );
        },
      ),
    );
  }
}
