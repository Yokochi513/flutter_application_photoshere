import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PostRepository {
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
}
