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
    print("Rating: $_rating");
    print("Comment: \$comment");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Feedback submitted (mock)")));

    setState(() {
      _rating = 0.0;
      _commentController.clear();
    });
  }

  final MapController controller = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFEFEF),
      appBar: AppBar(
        backgroundColor: TColor.primary,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {},
          icon: Image.asset("assets/img/menu.png", height: 20, width: 20),
        ),
        title: Text(
          "Request Accepting",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Image.asset("assets/img/back.png"),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/img/cleaning_done.png"),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: TColor.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                const Text(
                  "How was your job?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Andrew Smelyanski",
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 45,
                  unratedColor: Colors.white54,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 35),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Leave a comment",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xffF7F7F7),
                  ),
                ),
                const SizedBox(height: 16),
                RoundButton(title: "Submit", onPressed: _submitFeedback),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
