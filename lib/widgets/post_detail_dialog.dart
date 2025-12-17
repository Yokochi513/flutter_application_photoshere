import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/post.dart';

/// 投稿詳細を表示するダイアログウィジェット
///
/// 使い方（概略）:
/// - `Post` オブジェクトを受け取り、そのタイトル・説明・画像・座標などを表示します。
/// - 画像はスワイプで切替可能なギャラリーとして表示します。
/// - 画面幅が広い場合は画像とテキストを横並びに、狭い場合は縦並びにして
///   レスポンシブに見た目を変えます。
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
    // 画面サイズに基づいてダイアログと画像の高さを決める
    // - dialogHeight: 画面高さの75%を上限に、最大640pxに制限
    // - imageHeight: ダイアログ高さの約60%を画像領域に割り当て
    // こうすることで小さい画面でもレイアウトが崩れにくくなります。
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = math.min(screenHeight * 0.75, 640.0);
    final imageHeight = dialogHeight * 0.6;

    // Dialog を ConstrainedBox でラップして最大高さを指定します。
    // SizedBox(height: ...) のように厳密に固定するのではなく、
    // maxHeight を指定することで微小なオーバーフローを防ぎます。
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: dialogHeight),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded + SingleChildScrollView
              // - Expanded: ダイアログ内部で利用可能な残り高さを使う
              // - SingleChildScrollView: コンテンツが長くなった場合にスクロール可能にする
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル（最大2行に制限、あふれる場合は「...」で切る）
                      Text(
                        widget.post.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // レスポンシブな画像＋詳細レイアウト
                      // - LayoutBuilder で利用可能幅を取得して横並び/縦並びを切替
                      // - wide（900px以上）の場合は画像とテキストを横並びにする
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;

                          // テキスト詳細部分を定義（説明・座標・日時）
                          Widget details = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
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
                            ],
                          );

                          // 画像がある場合は imageWidget を組み合わせる
                          if (widget.post.imageUrls.isNotEmpty) {
                            final imageWidget = SizedBox(
                              height: imageHeight,
                              child: _buildImageGallery(context, imageHeight),
                            );

                            if (isWide) {
                              // 横並び: 画像（左）と詳細（右）を比率3:2で表示
                              return SizedBox(
                                height: imageHeight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 3, child: imageWidget),
                                    const SizedBox(width: 16),
                                    Expanded(flex: 2, child: details),
                                  ],
                                ),
                              );
                            } else {
                              // 縦並び: 画像の下に詳細を表示
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  imageWidget,
                                  const SizedBox(height: 8),
                                  details,
                                ],
                              );
                            }
                          } else {
                            // 画像が無い場合は詳細のみ表示
                            return details;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

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
    return Stack(
      children: [
        // 画像ページ表示（親が高さを制限している）
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.post.imageUrls.length,
          itemBuilder: (context, index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                // Use ~75% of available width for the image to make it more prominent
                final imageWidth = math.min(availableWidth * 0.75, availableWidth);

                return Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.post.imageUrls[index],
                      fit: BoxFit.contain,
                      width: imageWidth,
                      height: height,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          width: imageWidth,
                          height: height,
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),

        // 左右の操作ボタン
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
                  decoration: const BoxDecoration(
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
        if (widget.post.imageUrls.length > 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex < widget.post.imageUrls.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
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

        // 画像枚数インジケーター（画像領域の下部に重ねる）
        if (widget.post.imageUrls.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${widget.post.imageUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
