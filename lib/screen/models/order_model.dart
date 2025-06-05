// lib/screen/models/order_model.dart

/// Модель клиентского/клинерского заказа
class Order {
  final String id;
  final List<String> serviceIds;
  final String address;
  final String? comment;
  final String status;
  final double? price;

  /// Дата, когда уборка должна быть выполнена
  final DateTime scheduledAt;

  /// Дата создания заказа
  final DateTime createdAt;

  /// Тип уборки (например, "deep", "standard" и т.д.)
  final String cleaningType;

  /// Список участников (строк вида "Имя Фамилия")
  final List<String> participants;

  /// Рейтинг заказа (лишь для истории)
  final double? rating;

  /// Отзывы клиента по этому заказу (лишь для истории)
  final List<String>? reviews;

  const Order({
    required this.id,
    required this.serviceIds,
    required this.address,
    this.comment,
    required this.status,
    required this.scheduledAt,
    required this.createdAt,
    this.price,
    this.cleaningType = '',
    this.participants = const [],
    this.rating,
    this.reviews,
  });

  // ───────────────── factory: из JSON ─────────────────
  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(List<String> keys) {
      for (final k in keys) {
        final raw = json[k];
        if (raw != null && raw.toString().isNotEmpty) {
          return DateTime.parse(raw as String).toLocal();
        }
      }
      return DateTime.now();
    }

    // Выдергиваем участников
    List<String> _parseParticipants() {
      final rawList = json['participants'] as List<dynamic>? ?? [];
      return rawList.whereType<Map<String, dynamic>>().map((p) {
        final fn = p['first_name']?.toString() ?? '';
        final ln = p['last_name']?.toString() ?? '';
        return '$fn ${ln}'.trim();
      }).where((name) => name.isNotEmpty).toList();
    }

    // Выдергиваем отзывы (если есть)
    List<String>? _parseReviews() {
      final rawList = json['reviews'] as List<dynamic>?;
      if (rawList == null) return null;
      return rawList.whereType<String>().toList();
    }

    return Order(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      serviceIds: (json['service_ids'] ??
          json['services'] ??
          const <dynamic>[])
          .map<String>((e) => e.toString())
          .toList(),
      address: (json['address'] ?? '').toString(),
      comment: json['comment']?.toString(),
      status: (json['status'] ?? 'unknown').toString(),
      scheduledAt: _parseDate(['scheduled_at', 'scheduled_date', 'date']),
      createdAt: _parseDate(['created_at', 'created', 'createdAt']),
      price: (json['price'] ?? json['total_price'])?.toDouble(),
      cleaningType: (json['cleaning_type'] ?? '').toString(),
      participants: _parseParticipants(),
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : null,
      reviews: _parseReviews(),
    );
  }

  /// «Пустая» запись, чтобы использовать в качестве загрузочной заглушки.
  factory Order.placeholder() {
    final now = DateTime.now();
    return Order(
      id: '',
      serviceIds: const [],
      address: '',
      comment: null,
      status: 'loading',
      scheduledAt: now,
      createdAt: now,
      price: null,
      cleaningType: '',
      participants: const [],
      rating: null,
      reviews: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_ids': serviceIds,
    'address': address,
    'comment': comment,
    'status': status,
    'price': price,
    'scheduled_at': scheduledAt.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'cleaning_type': cleaningType,
    'participants': participants,
    'rating': rating,
    'reviews': reviews,
  };
}
