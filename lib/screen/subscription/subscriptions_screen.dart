import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/login/api_service.dart';
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
          return ListTile(
            title: Text(
                'Order ${s.orderId.substring(0, 6)}…  •  ${s.status}'),
            subtitle: Text(
                '${fmt.format(s.start)} → ${fmt.format(s.end)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(
                context, '/subs/edit',
                arguments: s).then((_) => _load()),
          );
        },
      ),
    );
  }
}
