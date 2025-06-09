import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/api/api_routes.dart';

class UploadPhotoScreen extends StatefulWidget {
  final String orderId;
  const UploadPhotoScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _UploadPhotoScreenState createState() => _UploadPhotoScreenState();
}

// lib/screen/order/cleaner/upload_photo_screen.dart

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  bool _busy = false;
  String? _err;

  String _fixHost(String url) =>
      url.replaceFirst('localhost:9000', '10.0.2.2:9000');

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _images
          ..clear()
          ..addAll(picked);
        _err = null;
      });
    }
  }

  // Исправляем метод _uploadAndComplete для правильной загрузки и завершения заказа
  Future<void> _uploadAndComplete() async {
    if (_images.isEmpty) return;

    setState(() {
      _busy = true;
      _err = null;
    });

    try {
      // 1) Загружаем фото и получаем URL
      final file = File(_images.first.path);
      final photoUrl = await ApiService.uploadReport(widget.orderId, file);

      // Исправляем URL для локального эмулятора
      final fixedUrl = photoUrl.replaceFirst('localhost:9000', '10.0.2.2:9000');

      // 2) Подтверждаем завершение заказа с URL фото
      final resp = await ApiService.confirmCompletion(widget.orderId, fixedUrl);

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Confirm failed: ${resp.statusCode} ${resp.body}');
      }

      if (!mounted) return;
      Navigator.of(context)
        ..pop(true) // в OrderDetailsScreen вернётся true
        ..pop();    // закроем OrderDetailsScreen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as finished')),
      );
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: TColor.background,
    appBar: AppBar(
      iconTheme: IconThemeData(color: TColor.primary),
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: const Text('Upload Photo Report',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select photos for order #${widget.orderId}',
                    style: TextStyle(
                      color: TColor.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_images.isEmpty)
                    Center(
                      child: Text('No photos selected',
                          style: TextStyle(color: TColor.textSecondary)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _images.map((x) {
                        return Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(x.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.remove(x)),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                          )
                        ]);
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick photos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TColor.primary,
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: TColor.primary),
                    ),
                  ),
                  if (_err != null) ...[
                    const SizedBox(height: 12),
                    Text(_err!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _busy || _images.isEmpty ? null : _uploadAndComplete,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: TColor.primary,
            ),
            child: _busy
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Text(
              'Upload & Complete',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}
