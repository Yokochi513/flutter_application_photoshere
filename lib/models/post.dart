class Post {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['imageUrl'].replaceAll(r'\', '/') ?? '';
    final fullUrl =
        rawUrl.startsWith('http') ? rawUrl : 'http://localhost:3000/$rawUrl';
    return Post(
      id: json['_id'],
      latitude: json['lat'],
      longitude: json['lng'],
      title: json['title'],
      description: json['description'],
      imageUrl: fullUrl,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
