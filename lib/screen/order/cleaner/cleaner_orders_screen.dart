import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/order/cleaner/cleaner_details_screen.dart';

class CleanerOrdersScreen extends StatefulWidget {
  const CleanerOrdersScreen({super.key});

  @override
  State<CleanerOrdersScreen> createState() => _CleanerOrdersScreenState();
}

class _CleanerOrdersScreenState extends State<CleanerOrdersScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '1',
      'title': 'Cleaning Order #1',
      'address': 'Abay St, 25',
      'startTime': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Waiting to start',
      'cleaningType': 'Initial Cleaning',
      'frequency': 'Monthly',
      'extras': ['Carpet', 'Windows'],
    },
    {
      'id': '2',
      'title': 'Cleaning Order #2',
      'address': 'Nazarbayev Ave, 13',
      'startTime': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'status': 'In progress',
      'cleaningType': 'Upkeep Cleaning',
      'frequency': 'Weekly',
      'extras': ['Disinfection'],
    },
  ];

  final ImagePicker _picker = ImagePicker();
  String? _currentOrderIdFinishing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = _orders[index];
            final DateTime startTime = order['startTime'];
            final startTimeFormatted =
                "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.day}/${startTime.month}/${startTime.year}";

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF7EC),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['address'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start time: $startTimeFormatted',
                    style: TextStyle(fontSize: 14, color: TColor.secondaryText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Status: ${order['status']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundButton(
                        title: 'Details',
                        width: 120,
                        height: 40,
                        fontSize: 14,
                        onPressed: () => _showOrderDetails(order),
                      ),
                      if (order['status'] != 'Finished')
                        RoundButton(
                          title: 'Finish Order',
                          width: 140,
                          height: 40,
                          fontSize: 14,
                          type: RoundButtonType.secondary,
                          onPressed: () {
                            _currentOrderIdFinishing = order['id'];
                            _showFinishOrderDialog(order);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderDetailsScreen(
              orderTitle: order['title'] ?? 'Order',
              address: order['street'] ?? '',
              startTime:
                  order['startTime'] != null
                      ? order['startTime'].toString()
                      : '',
              status: order['status'] ?? '',
              extras: order['extras'] ?? [],
              onFinish: () {
                if (_currentOrderIdFinishing != null) {
                  _markOrderAsFinished(_currentOrderIdFinishing!);
                }
              },
            ),
      ),
    );
  }

  void _showFinishOrderDialog(Map<String, dynamic> order) {
    File? pickedImage;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    'Finish Order',
                    style: TextStyle(color: TColor.primaryText),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Please upload a photo after finishing the order:',
                        style: TextStyle(color: TColor.primaryText),
                      ),
                      const SizedBox(height: 10),
                      pickedImage == null
                          ? GestureDetector(
                            onTap: () async {
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  pickedImage = File(image.path);
                                });
                              }
                            },
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: TColor.primary),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.photo_library,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          : Stack(
                            children: [
                              Image.file(
                                pickedImage!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: InkWell(
                                  onTap:
                                      () => setState(() => pickedImage = null),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    RoundButton(
                      title: 'Finish',
                      onPressed: () {
                        if (pickedImage != null &&
                            _currentOrderIdFinishing != null) {
                          Navigator.pop(context);
                          _markOrderAsFinished(_currentOrderIdFinishing!);
                        }
                      },
                      type: RoundButtonType.primary,
                      height: 40,
                      width: 100,
                      fontSize: 14,
                    ),
                  ],
                ),
          ),
    );
  }

  void _markOrderAsFinished(String orderId) {
    setState(() {
      final index = _orders.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        _orders[index]['status'] = 'Finished';
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order marked as finished')));
  }
}
