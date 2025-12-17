import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PostService {
  // 単一画像アップロード
  static Future<bool> uploadPost({
    required double latitude,
    required double longitude,
    required String title,
    required String description,
    required Uint8List imageBytes,
  }) async {
    final uri = Uri.parse('http://localhost:3000/api/posts');

    var request = http.MultipartRequest('POST', uri)
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..fields['title'] = title
      ..fields['description'] = description;

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpeg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    var response = await request.send();
    return response.statusCode == 201;
  }

  // 複数画像アップロード
  static Future<bool> uploadPostMultiple({
    required double latitude,
    required double longitude,
    required String title,
    required String description,
    required List<XFile> images,
  }) async {
    final uri = Uri.parse('http://localhost:3000/api/posts');

    var request = http.MultipartRequest('POST', uri)
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..fields['title'] = title
      ..fields['description'] = description;

    for (int i = 0; i < images.length; i++) {
      final bytes = await images[i].readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          bytes,
          filename: 'image_$i.jpeg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    var response = await request.send();
    return response.statusCode == 201;
  }

  static Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('http://localhost:3000/api/posts');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      debugPrint(response.body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
