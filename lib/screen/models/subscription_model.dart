import 'dart:convert';

/// Модель расписания (ScheduleSpec)
class ScheduleSpec {
  final String frequency;       // “weekly”, “biweekly” и т.д.
  final List<String> daysOfWeek;  // ["Mon", "Wed", ...]
  final List<int> weekNumbers;    // [1, 3] для biweekly и т.д.

  ScheduleSpec({
    required this.frequency,
    required this.daysOfWeek,
    required this.weekNumbers,
  });

  factory ScheduleSpec.fromJson(Map<String, dynamic> json) {
    return ScheduleSpec(
      frequency: json['frequency'] as String,
      daysOfWeek: List<String>.from(json['days_of_week'] ?? []),
      weekNumbers: List<int>.from(json['week_numbers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'days_of_week': daysOfWeek,
      'week_numbers': weekNumbers,
    };
  }
}

/// Основная модель подписки (Subscription), соответствующая Go-структуре:
/// id, order_id, user_id, start_date, end_date, schedule, price, status, created_at, updated_at, last_order_date, next_planned_date :contentReference[oaicite:1]{index=1}
class Subscription {
  String id;
  String orderId;
  String userId;
  DateTime startDate;
  DateTime endDate;
  ScheduleSpec schedule;
  double price;
  String status; // “active”, “expired”, “cancelled”
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastOrderDate;
  DateTime? nextPlannedDate;

  Subscription({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.schedule,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastOrderDate,
    this.nextPlannedDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String).toLocal(),
      endDate: DateTime.parse(json['end_date'] as String).toLocal(),
      schedule: ScheduleSpec.fromJson(json['schedule'] as Map<String, dynamic>),
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'] as String).toLocal()
          : null,
      nextPlannedDate: json['next_planned_date'] != null
          ? DateTime.parse(json['next_planned_date'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate.toUtc().toIso8601String(),
      'schedule': schedule.toJson(),
      'price': price,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      if (lastOrderDate != null)
        'last_order_date': lastOrderDate!.toUtc().toIso8601String(),
      if (nextPlannedDate != null)
        'next_planned_date': nextPlannedDate!.toUtc().toIso8601String(),
    };
  }
}
