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

  List<XFile> _images = [];

  // 複数画像選択
  Future<void> pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  // 個別画像削除
  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
              "画像選択(複数可)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickImages,
              child: Container(
                padding: const EdgeInsets.all(4),
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _images.isEmpty
                    ? const Center(child: Text("タップして画像を選択"))
                    : SizedBox(
                        height: 200,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, mainAxisSpacing: 4),
                          itemCount: _images.length,
                          itemBuilder: (_, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<Uint8List>(
                                    future: _images[index].readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: 150,
                                        );
                                      } else {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          width: 150,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => removeImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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
                  if (_images.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("画像を選択してください"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final success = await PostService.uploadPostMultiple(
                    latitude: widget.pos.latitude,
                    longitude: widget.pos.longitude,
                    title: titleCtrl.text,
                    description: descriptionCtrl.text,
                    images: _images,
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
