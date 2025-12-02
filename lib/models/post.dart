class Post {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final List<String> imageUrls;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final List<String> urls =
        (json['imageUrls'] as List<dynamic>? ?? []).map((e) {
      final rawUrl = e.toString().replaceAll(r'\', '/');
      return rawUrl.startsWith('http')
          ? rawUrl
          : 'http://localhost:3000/$rawUrl';
    }).toList();

    print("Image URLs:");
    print(urls);

    return Post(
      id: json['_id'],
      latitude: json['lat'],
      longitude: json['lng'],
      title: json['title'],
      description: json['description'],
      imageUrls: urls,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
