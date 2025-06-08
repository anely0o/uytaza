// lib/screen/order/cleaner/upload_photo_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/common/color_extension.dart';
import '../../api/api_service.dart';

class UploadPhotoScreen extends StatefulWidget {
  final String orderId;
  const UploadPhotoScreen({super.key, required this.orderId});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  bool _busy = false;
  String? _err;

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

  Future<void> _upload() async {
    if (_images.isEmpty) return;

    setState(() {
      _busy = true;
      _err = null;
    });

    try {
      // 1) upload all photos and get URLs
      final files = _images.map((x) => File(x.path)).toList();
      final urls = await ApiService.uploadMediaAndGetUrls(
          widget.orderId, files);

      // 2) confirm completion with the first photo URL
      final firstUrl = urls.first;
      final respConfirm =
      await ApiService.confirmCompletion(widget.orderId, firstUrl);

      if (respConfirm.statusCode >= 200 && respConfirm.statusCode < 300) {
        if (!mounted) return;

        // pop back twice (to CleanerOrdersScreen) and then show a snackbar
        Navigator.of(context)
          ..pop(
              true) // this pop returns true to the caller of UploadPhotoScreen
          ..pop(); // this pop closes the history/detail and returns to cleaner list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order marked as finished')),
        );
      } else {
        throw Exception(
            'Confirm failed: ${respConfirm.statusCode} ${respConfirm.body}');
      }
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        backgroundColor: TColor.background,
        appBar: AppBar(
          iconTheme: IconThemeData(color: TColor.primary),
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text('Upload Photo Report',
              style: TextStyle(fontWeight: FontWeight.bold)),
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
                              style:
                              TextStyle(color: TColor.textSecondary)),
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
                                  onTap: () =>
                                      setState(() {
                                        _images.remove(x);
                                      }),
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
                onPressed: _busy || _images.isEmpty ? null : _upload,
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
                    : const Text('Upload & Complete',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
}