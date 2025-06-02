import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/models/order_model.dart';
import 'package:uytaza/api/api_service.dart';
import 'order_build_page.dart';
import 'order_edit_page.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  Map<String, String> _serviceNames = {};
  bool _loading = true;
  String? _error;
  String _statusFilter = 'all';
  DateTime? _dateFilter;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchServices();
    await _fetchOrders();
  }

  Future<void> _fetchServices() async {
    try {
      final response = await ApiService.getWithToken('/api/services/active');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _serviceNames = {
            for (var item in data)
              item['id'].toString(): item['name'] ?? 'Unnamed Service'
          };
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await ApiService.getWithToken('/api/orders/my');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _orders = data.map((e) => Order.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load orders';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteOrder(String id) async {
    try {
      final res = await ApiService.deleteWithToken('/api/orders/$id');
      if (res.statusCode == 200 || res.statusCode == 204) {
        _fetchOrders();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((order) {
      final matchesStatus = _statusFilter == 'all' || order.status == _statusFilter;
      final matchesDate = _dateFilter == null ||
          DateFormat('yyyy-MM-dd').format(order.scheduledAt) ==
              DateFormat('yyyy-MM-dd').format(_dateFilter!);
      return matchesStatus && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Your Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderBuildPage()),
              );
              if (result is Order) _fetchOrders();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _statusFilter,
                  items: ['all','assigned', 'processing', 'completed', 'cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _statusFilter = val!);
                  },
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_dateFilter == null
                      ? "Pick date"
                      : DateFormat('yyyy-MM-dd').format(_dateFilter!)),
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
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dateFilter = null),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredOrders.isEmpty
                  ? const Center(
                child: Text(
                  'No matching orders.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(order.scheduledAt);
                  final serviceNames = order.serviceIds
                      .map((id) => _serviceNames[id] ?? id)
                      .join(', ');

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Services: $serviceNames',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: ${order.address}'),
                          if (order.comment != null && order.comment!.isNotEmpty)
                            Text('Comment: ${order.comment}'),
                          Text('Date: $formattedDate'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: order.status == 'completed'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(
                                    color: order.status == 'completed'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderEditPage(orderId: order.id),
                                    ),
                                  );
                                  if (updated == true) _fetchOrders();
                                },
                                child: const Text("Edit"),
                              ),

                              TextButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Confirm'),
                                      content: const Text('Delete this order?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text("No")),
                                        TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text("Yes")),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await _deleteOrder(order.id);
                                  }
                                },
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
