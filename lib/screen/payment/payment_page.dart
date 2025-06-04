// lib/screen/payment/payment_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/order/client/order_success_page.dart';

class PaymentPage extends StatefulWidget {
  final String entityType; // Например: "order"
  final String entityId;   // ID вашего заказа
  final String? userId;    // Может приходить null, если мы будем брать из токена
  final int amount;        // Сумма в тенге (int), должна быть > 0

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
    // Если userId не передали в конструкторе, пытаемся получить из токена
    if (widget.userId == null || widget.userId!.isEmpty) {
      _extractUserIdFromToken();
    } else {
      _resolvedUserId = widget.userId;
    }
  }

  /// Попытка извлечь user_id из JWT-токена.
  Future<void> _extractUserIdFromToken() async {
    try {
      // Здесь предполагаем, что ApiService.getToken() возвращает вашу JWT-строку.
      // Если в вашем ApiService другой метод – замените на него.
      final rawToken = await ApiService.getToken();
      if (rawToken == null || rawToken.isEmpty) {
        setState(() {
          _error = 'JWT-токен не найден';
        });
        return;
      }
      final parts = rawToken.split('.');
      if (parts.length != 3) {
        setState(() {
          _error = 'Неверный формат JWT-токена';
        });
        return;
      }
      // Берём среднюю часть (payload), декодируем из Base64Url → JSON → Map
      final payloadBase64 = parts[1];
      // Важно: выравниваем Base64Url (дополняем “=”, если нужно)
      String normalized = base64Url.normalize(payloadBase64);
      final payloadBytes = base64Url.decode(normalized);
      final Map<String, dynamic> payloadMap = jsonDecode(utf8.decode(payloadBytes));

      // Обычно в JWT поле с user ID называется "sub" или "user_id" – уточните у бэкенда.
      // Здесь проверим разные варианты:
      final maybeId = (payloadMap['user_id'] ??
          payloadMap['sub'] ??
          payloadMap['id'])?.toString();

      if (maybeId == null || maybeId.isEmpty) {
        setState(() {
          _error = 'Не удалось извлечь user_id из токена';
        });
        return;
      }

      // Всё получилось:
      setState(() {
        _resolvedUserId = maybeId;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка извлечения user_id из токена: $e';
      });
    }
  }

  Future<void> _doPayment() async {
    // 1) Проверяем, что сумма > 0
    if (widget.amount <= 0) {
      setState(() {
        _error = 'Сумма должна быть больше нуля';
      });
      return;
    }

    // 2) Убедимся, что у нас есть user_id
    if (_resolvedUserId == null || _resolvedUserId!.isEmpty) {
      setState(() {
        _error = 'Идёт поиск user_id... Подождите';
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
      // 3) Отправляем запрос на "/api/payments"
      final res = await ApiService.postWithToken('/api/payments', body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Успешно, переходим на страницу успеха
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
        );
      } else {
        // 4) Если сервер вернул ошибку, пытаемся распарсить JSON либо показать "сырой" текст
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
        _error = 'Ошибка платежа: $e';
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
            // Карточка с информацией о платеже
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

            // Показ ошибки, если она есть
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            const Spacer(),

            // Если user_id ещё не определён, показываем круговую загрузку
            if (_resolvedUserId == null)
              const Center(child: CircularProgressIndicator()),

            // Если user_id есть – отображаем кнопку "Pay Now"
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
