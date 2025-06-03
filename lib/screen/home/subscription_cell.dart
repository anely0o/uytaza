import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';

class SubscriptionCell extends StatelessWidget {
  final Map obj;
  final VoidCallback onPressed;

  const SubscriptionCell({
    super.key,
    required this.obj,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: context.width * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                obj["img"] as String? ?? "",
                width: double.infinity,
                height: context.width * 0.4,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              obj["title"] as String? ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              obj["subtitle"] as String? ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(color: TColor.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
