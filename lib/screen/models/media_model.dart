class Media {
  final String id;
  final String fileName;
  final String objectKey;
  final String URL;
  final String type;
  final String? orderId;
  final String userId;
  final DateTime createdAt;

  Media({
    required this.id,
    required this.fileName,
    required this.objectKey,
    required this.URL,
    required this.type,
    this.orderId,
    required this.userId,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['ID'] as String,
      fileName: json['FileName'] as String,
      objectKey: json['ObjectKey'] as String,
      URL: json['URL'] as String,
      // <-- правильно читаем URL
      type: json['Type'] as String,
      orderId: (json['OrderID'] as String?)?.isEmpty == true
          ? null
          : json['OrderID'] as String?,
      userId: json['UserID'] as String,
      createdAt: DateTime.parse(
          json['CreatedAt'] as String), // <-- CreatedAt с заглавной
    );
  }


Map<String, dynamic> toJson() => {
    'ID': id,
    'FileName': fileName,
    'ObjectKey': objectKey,
    'URL': URL,
    'Type': type,
    'OrderID': orderId ?? '',
    'UserID': userId,
    'CreatedAt': createdAt.toIso8601String(),
  };
}
