import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';

class ImagePickerScreen extends StatefulWidget {
  final Function(String) didSelect;
  const ImagePickerScreen({super.key, required this.didSelect});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width * 0.8,
      height: context.height * 0.4,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: TColor.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Image Picker",
            style: TextStyle(
              color: TColor.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _getImageCamera();
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 100,
                    color: TColor.primary,
                  ),
                ),
              ),

              Expanded(
                child: TextButton(
                  onPressed: () {
                    _getImageGallery();
                  },
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: TColor.primary,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Take Photo",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: Text(
                  "Gallery",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(
                  "Close",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _getImageCamera() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        widget.didSelect(pickedFile.path);
      }
      context.pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getImageGallery() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        widget.didSelect(pickedFile.path);
      }
      context.pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
