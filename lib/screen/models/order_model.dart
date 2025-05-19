class Order {
  final String cleaningType;
  final String frequency;
  final DateTime dateTime;
  final List<String> extras;
  String status; // например, "processing", "completed"

  Order({
    required this.cleaningType,
    required this.frequency,
    required this.dateTime,
    required this.extras,
    this.status = 'In Progress',
  });

  Order copyWith({
    String? cleaningType,
    String? frequency,
    List<String>? extras,
    DateTime? date,
    String? status,
  }) {
    return Order(
      cleaningType: cleaningType ?? this.cleaningType,
      frequency: frequency ?? this.frequency,
      extras: extras ?? this.extras,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
    );
  }
}
