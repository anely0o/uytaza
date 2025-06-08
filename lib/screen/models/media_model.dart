class Media {
  final String id;
  final String url;

  Media({required this.id, required this.url});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['_id'] as String,
      url: json['url'] as String,
    );
  }
}
