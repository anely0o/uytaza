import 'dart:convert';

class Subscription {
  final String id;
  final String orderId;
  final DateTime start;
  late final DateTime end;
  final List<int> days;     // 1..7
  final String status;

  Subscription({
    required this.id,
    required this.orderId,
    required this.start,
    required this.end,
    required this.days,
    required this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> j) {
    final _dayToIndex = {
      'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4,
      'Fri': 5, 'Sat': 6, 'Sun': 7,
    };

    return Subscription(
      id      : j['id'] ?? j['_id'],
      orderId : j['order_id'],
      start   : DateTime.parse(j['start_date']).toLocal(),
      end     : DateTime.parse(j['end_date']).toLocal(),
      days    : (j['days_of_week'] as List)
          .map((e) => _dayToIndex[e] ?? 0)
          .where((i) => i != 0)
          .toList(),
      status  : j['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'start_date'  : start.toUtc().toIso8601String(),
    'end_date'    : end.toUtc().toIso8601String(),
    'days_of_week': days.map((e)=>e.toString()).toList(),
  };
}
