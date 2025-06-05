// lib/screen/payment/payment_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/order/client/order_success_page.dart';

class PaymentPage extends StatefulWidget {
  final String entityType; // For example: "order"
  final String entityId;   // Your order ID
  final String? userId;    // May be null if we fetch it from the token
  final int amount;        // Amount in tenge (int), must be > 0

  const PaymentPage({
    super.key,
    required this.entityType,
    required this.entityId,
    this.userId,
    required this.amount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;
  String? _error;
  String? _resolvedUserId;

  @override
  void initState() {
    super.initState();
    // If userId wasn't passed into the constructor, try to get it from the token
    if (widget.userId == null || widget.userId!.isEmpty) {
      _extractUserIdFromToken();
    } else {
      _resolvedUserId = widget.userId;
    }
  }

  /// Attempt to extract user_id from the JWT token.
  Future<void> _extractUserIdFromToken() async {
    try {
      // Assume ApiService.getToken() returns your raw JWT string.
      // If your ApiService uses a different method, replace it accordingly.
      final rawToken = await ApiService.getToken();
      if (rawToken == null || rawToken.isEmpty) {
        setState(() {
          _error = 'JWT token not found';
        });
        return;
      }
      final parts = rawToken.split('.');
      if (parts.length != 3) {
        setState(() {
          _error = 'Invalid JWT token format';
        });
        return;
      }
      // Take the middle part (payload), decode from Base64Url → JSON → Map
      final payloadBase64 = parts[1];
      // Important: normalize Base64Url (add "=" padding if needed)
      String normalized = base64Url.normalize(payloadBase64);
      final payloadBytes = base64Url.decode(normalized);
      final Map<String, dynamic> payloadMap = jsonDecode(utf8.decode(payloadBytes));

      // Typically the user ID field in JWT is called "sub" or "user_id"—confirm with your backend.
      // Here we check various possible keys:
      final maybeId = (payloadMap['user_id'] ??
          payloadMap['sub'] ??
          payloadMap['id'])?.toString();

      if (maybeId == null || maybeId.isEmpty) {
        setState(() {
          _error = 'Failed to extract user_id from token';
        });
        return;
      }

      // Success:
      setState(() {
        _resolvedUserId = maybeId;
      });
    } catch (e) {
      setState(() {
        _error = 'Error extracting user_id from token: $e';
      });
    }
  }

  Future<void> _doPayment() async {
    // 1) Check that amount > 0
    if (widget.amount <= 0) {
      setState(() {
        _error = 'Amount must be greater than zero';
      });
      return;
    }

    // 2) Ensure we have a user_id
    if (_resolvedUserId == null || _resolvedUserId!.isEmpty) {
      setState(() {
        _error = 'Looking up user_id... Please wait';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final body = {
      "entity_type": widget.entityType,
      "entity_id": widget.entityId,
      "user_id": _resolvedUserId,
      "amount": widget.amount,
    };

    try {
      // 3) Send request to "/api/payments"
      final res = await ApiService.postWithToken('/api/payments', body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Success, navigate to the success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
        );
      } else {
        // 4) If server returned an error, try to parse JSON or show raw text
        String serverMessage;
        try {
          final decoded = jsonDecode(res.body);
          serverMessage = decoded['error'] ?? decoded['message'] ?? 'HTTP ${res.statusCode}';
        } catch (_) {
          serverMessage = res.body.isNotEmpty ? res.body : 'HTTP ${res.statusCode}';
        }
        throw serverMessage;
      }
    } catch (e) {
      setState(() {
        _error = 'Payment error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = widget.amount.toString();

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: TColor.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card with payment information
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Order ID:',
                      style: TextStyle(
                        fontSize: 14,
                        color: TColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.entityId,
                      style: TextStyle(
                        fontSize: 16,
                        color: TColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Amount to pay:',
                      style: TextStyle(
                        fontSize: 16,
                        color: TColor.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$displayAmount ₸',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Show error message if present
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            const Spacer(),

            // If user_id is still being fetched, show a loading indicator
            if (_resolvedUserId == null)
              const Center(child: CircularProgressIndicator()),

            // If user_id is available – show "Pay Now" button
            if (_resolvedUserId != null)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _doPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
