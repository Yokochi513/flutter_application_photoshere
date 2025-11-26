import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../services/post_service.dart';

class PostFormSheet extends StatefulWidget {
  final LatLng pos;

  const PostFormSheet({
    super.key,
    required this.pos,
  });

  @override
  State<PostFormSheet> createState() => _PostFormSheetState();
}

class _PostFormSheetState extends State<PostFormSheet> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _image;

  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (picked != null) {
      _image = await picked.readAsBytes();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("投稿フォーム", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text("緯度: ${widget.pos.latitude}"),
            Text("経度: ${widget.pos.longitude}"),
            const SizedBox(height: 20),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: "タイトル",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "説明",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "画像選択",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null
                    ? const Center(
                        child: Text("タップして画像を選択"),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 投稿ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("投稿する"),
                onPressed: () async {
                  if (_image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("画像を選択してください"),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  final success = await PostService.uploadPost(
                    latitude: widget.pos.latitude,
                    longitude: widget.pos.longitude,
                    title: titleCtrl.text,
                    description: descriptionCtrl.text,
                    imageBytes: _image!,
                  );

                  if (success) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("投稿に失敗しました")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
