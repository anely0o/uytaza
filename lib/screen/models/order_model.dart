/// Модель клиентского заказа
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

  const Order({
    required this.id,
    required this.serviceIds,
    required this.address,
    this.comment,
    required this.status,
    required this.scheduledAt,
    required this.createdAt,
    this.price,
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

    return Order(
      id         : (json['id'] ?? json['_id'] ?? '').toString(),
      serviceIds : (json['service_ids'] ??
          json['services']    ??
          const <dynamic>[] )
          .map<String>((e) => e.toString()).toList(),
      address    : (json['address'] ?? '').toString(),
      comment    : json['comment']?.toString(),
      status     : (json['status'] ?? 'unknown').toString(),
      scheduledAt: _parseDate(['date', 'scheduled_date']),
      createdAt  : _parseDate(['created_at', 'created']),
      price      : (json['price'] ?? json['total_price'])?.toDouble(),
    );
  }

  /// «Пустая» запись, чтобы использовать в качестве загрузочной заглушки.
  factory Order.placeholder() {
    final now = DateTime.now();
    return Order(
      id         : '',
      serviceIds : const [],
      address    : '',
      comment    : null,
      status     : 'loading',
      scheduledAt: now,
      createdAt  : now,
      price      : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id'          : id,
    'service_ids' : serviceIds,
    'address'     : address,
    'comment'     : comment,
    'status'      : status,
    'price'       : price,
    'date'        : scheduledAt.toIso8601String(),
    'created_at'  : createdAt.toIso8601String(),
  };
}