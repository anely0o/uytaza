import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: const Text(
          "About Us",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [TColor.primary, TColor.secondary.withOpacity(1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Who We Are",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "We are a team dedicated to making your spaces shine. Our services are designed to bring comfort, cleanliness, and calm to your daily life.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Our Mission",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "To provide top-quality, eco-friendly cleaning services with professionalism, care, and a personal touch.",
                    style: TextStyle(
                      fontSize: 15,
                      color: TColor.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Our Vision",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We aim to be your most trusted home cleaning solution, offering convenience and peace of mind in every visit.",
                    style: TextStyle(
                      fontSize: 15,
                      color: TColor.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Contact Us",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "📞 Phone: +7 775 270 4135\n📧 Email: contact@uytaza.kz\n📍 Address: Mangilik El C1, Astana",
                    style: TextStyle(
                      fontSize: 15,
                      color: TColor.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
