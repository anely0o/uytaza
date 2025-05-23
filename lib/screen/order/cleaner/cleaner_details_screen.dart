import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common_widget/round_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderTitle;
  final String address;
  final String startTime; // например, "12 May 2025, 14:00"
  final String status;
  final List<String> extras;
  final VoidCallback onFinish; // callback для обновления статуса в списке

  const OrderDetailsScreen({
    super.key,
    required this.orderTitle,
    required this.address,
    required this.startTime,
    required this.status,
    required this.extras,
    required this.onFinish,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void _finishOrder() {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo before finishing the order.'),
        ),
      );
      return;
    }

    // Логика отправки фото и обновления статуса
    // Тут обычно API вызов, но для примера просто вызовем колбек и закроем экран
    widget.onFinish();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.orderTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          children: [
            _infoRow('Address', widget.address),
            const SizedBox(height: 12),
            _infoRow('Start Time', widget.startTime),
            const SizedBox(height: 12),
            _infoRow('Status', widget.status),
            const SizedBox(height: 20),
            const Text(
              'Extras',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children:
                  widget.extras
                      .map(
                        (extra) => Chip(
                          backgroundColor: TColor.secondary.withOpacity(0.2),
                          label: Text(
                            extra,
                            style: TextStyle(
                              color: TColor.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 30),
            _pickedImage == null
                ? InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TColor.primary),
                    ),
                    child: Center(
                      child: Text(
                        'Tap to upload photo',
                        style: TextStyle(
                          color: TColor.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
                : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _pickedImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => setState(() => _pickedImage = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 30),
            RoundButton(
              title: 'Finish',
              onPressed: _finishOrder,
              height: 55,
              fontWeight: FontWeight.bold,
              radius: 15,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColor.primaryText,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: TColor.secondaryText, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
