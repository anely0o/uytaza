import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/order/client/payment_method_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String selectedPlan = 'monthly';

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Get Premium",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Unlock all the power of this mobile tool and\n"
                "enjoy digital experience like never before!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              Image.asset("assets/img/credit_card.png", height: 150),
              const SizedBox(height: 30),
              _buildPlanOption(
                title: "Annual",
                subtitle: "First 30 days free – Then \$99/Year",
                isSelected: selectedPlan == 'annual',
                badge: "Best Value",
                onTap: () => setState(() => selectedPlan = 'annual'),
              ),
              const SizedBox(height: 15),
              _buildPlanOption(
                title: "Monthly",
                subtitle: "First 7 days free – Then \$9.99/Month",
                isSelected: selectedPlan == 'monthly',
                onTap: () => setState(() => selectedPlan = 'monthly'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _navigateToPayment,
                child: const Text(
                  "Start 7-day free trial",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text.rich(
                TextSpan(
                  text: "By placing this order, you agree to the ",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                  children: [
                    TextSpan(
                      text: "Terms of Service ",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: "and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextSpan(
                      text:
                          ". Subscription automatically renews unless auto-renew is "
                          "turned off at least 24-hours before the end of the current period.",
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? TColor.secondary : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            color: TColor.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isSelected ? TColor.secondaryText : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
