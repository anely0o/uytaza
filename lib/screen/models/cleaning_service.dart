class CleaningService {
  final String id;
  final String name;
  final double price;

  CleaningService.fromJson(Map<String, dynamic> j)
      : id = j['_id'] ?? j['id'],
        name = j['name'],
        price = (j['price'] as num).toDouble();
}