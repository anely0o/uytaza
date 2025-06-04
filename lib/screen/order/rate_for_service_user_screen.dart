import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/order/client/orders_screen.dart';

class RateForServiceUserScreen extends StatefulWidget {
  const RateForServiceUserScreen({super.key});

  @override
  State<RateForServiceUserScreen> createState() =>
      _RateForServiceUserScreenState();
}

class _RateForServiceUserScreenState extends State<RateForServiceUserScreen> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  void _submitFeedback() {
    final comment = _commentController.text;
    // For now, just a mock. Replace with real API call if needed.
    print("Rating: $_rating");
    print("Comment: $comment");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted (mock)")),
    );

    setState(() {
      _rating = 0.0;
      _commentController.clear();
    });
  }

  final MapController controller = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: TColor.primary),
        ),
        title: Text(
          "Request Accepting",
          style: TextStyle(
            color: TColor.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/img/cleaning_done.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: TColor.softShadow,
            ),
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Text(
                  "How was your job?",
                  style: TextStyle(
                    color: TColor.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Andrew Smelyanski",
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 45,
                  unratedColor: Colors.grey.shade300,
                  itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Leave a comment",
                    hintStyle: TextStyle(color: TColor.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.divider),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                RoundButton(
                  title: "Submit",
                  backgroundColor: TColor.primary,
                  textColor: Colors.white,
                  onPressed: _submitFeedback,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
