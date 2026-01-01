import 'package:flutter/material.dart';
import '../models/post.dart';
import 'tag_list.dart';

class PostInfo extends StatelessWidget {
  final Post post;
  final TextStyle? descriptionStyle;

  const PostInfo({
    super.key,
    required this.post,
    this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    final descStyle = descriptionStyle ?? Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          post.description,
          style: descStyle,
        ),
        const SizedBox(height: 8),
        TagList(tags: post.tags),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Text('緯度: ${post.latitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall),
            Text('経度: ${post.longitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Text('投稿日時: ${post.createdAt.toString().split('.')[0]}',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
