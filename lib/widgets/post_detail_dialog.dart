import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/post.dart';
import 'image_gallery.dart';
import 'post_info.dart';

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
  @override
  Widget build(BuildContext context) {
    // 画面サイズに基づいてダイアログと画像の高さを決める
    // - dialogHeight: 画面高さの75%を上限に、最大640pxに制限
    // - imageHeight: ダイアログ高さの約60%を画像領域に割り当て
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = math.min(screenWidth * 0.75, 700.0);
    final dialogHeight = math.min(screenHeight * 0.75, 640.0);
    final imageHeight = dialogHeight * 0.6;

    final baseTitleStyle = Theme.of(context).textTheme.titleLarge;
    final titleStyle = (baseTitleStyle != null)
        ? baseTitleStyle.copyWith(
            fontSize: (baseTitleStyle.fontSize ?? 20) * 1.15,
          )
        : const TextStyle(fontSize: 22, fontWeight: FontWeight.w600);

    final baseDescriptionStyle = Theme.of(context).textTheme.bodyMedium;
    final descriptionStyle = (baseDescriptionStyle != null)
        ? baseDescriptionStyle.copyWith(
            fontSize: (baseDescriptionStyle.fontSize ?? 14) * 1.25,
          )
        : const TextStyle(fontSize: 16);

    // Dialog を ConstrainedBox でラップして最大高さを指定します。
    // SizedBox(height: ...) のように厳密に固定するのではなく、
    // maxHeight を指定することで微小なオーバーフローを防ぎます。
    return Dialog(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: dialogHeight, maxWidth: dialogWidth),
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
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // レスポンシブな画像＋詳細レイアウト
                      // - LayoutBuilder で利用可能幅を取得して横並び/縦並びを切替
                      // - wide（900px以上）の場合は画像とテキストを横並びにする
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // テキスト詳細部分は共通ウィジェットに切り出しました
                          final details = PostInfo(
                            post: widget.post,
                            descriptionStyle: descriptionStyle,
                          );

                          // 画像がある場合は ImageGallery ウィジェットを組み合わせる
                          final imageWidget = SizedBox(
                            height: imageHeight,
                            child: ImageGallery(
                                imageUrls: widget.post.imageUrls,
                                height: imageHeight),
                          );

                          // 縦並び: 画像の下に詳細を表示
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              imageWidget,
                              const SizedBox(height: 8),
                              details,
                            ],
                          );
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

  // ギャラリー関連の実装は `ImageGallery` に移動しました。
}
