import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/post.dart';

/// 投稿詳細を表示するダイアログウィジェット
class PostDetailDialog extends StatefulWidget {
  final Post post;

  const PostDetailDialog({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailDialog> createState() => _PostDetailDialogState();
}

class _PostDetailDialogState extends State<PostDetailDialog> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = math.min(screenHeight * 0.75, 640.0);
    final imageHeight = math.min(dialogHeight * 0.42, 320.0);

    return Dialog(
      child: SizedBox(
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              Text(
                widget.post.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 画像表示（複数対応）
              if (widget.post.imageUrls.isNotEmpty)
                SizedBox(
                  height: imageHeight,
                  child: _buildImageGallery(context, imageHeight),
                ),
              const SizedBox(height: 12),

              // 説明（高さ制限して最大表示行数を設定）
              Text(
                widget.post.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 座標と日時をコンパクトに表示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '緯度: ${widget.post.latitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '経度: ${widget.post.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '投稿日時: ${widget.post.createdAt.toString().split('.')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const Spacer(),

              // 閉じるボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('閉じる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 複数画像をスワイプで表示するギャラリーウィジェット
  Widget _buildImageGallery(BuildContext context, double height) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: widget.post.imageUrls.length,
                itemBuilder: (context, index) {
                  // Preserve aspect ratio and ensure the whole image is visible
                  return Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.post.imageUrls[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: height,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              // 左矢印ボタン
              if (widget.post.imageUrls.length > 1)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentImageIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              // 右矢印ボタン
              if (widget.post.imageUrls.length > 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentImageIndex <
                            widget.post.imageUrls.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 画像枚数インジケーター
        if (widget.post.imageUrls.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${widget.post.imageUrls.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
