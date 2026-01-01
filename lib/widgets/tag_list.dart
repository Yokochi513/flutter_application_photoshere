import 'package:flutter/material.dart';

/// タグを表示するウィジェット
class TagList extends StatelessWidget {
  final List<String> tags;

  const TagList({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags.map((tag) {
        return Chip(
          label: Text(
            '#$tag',
            style: const TextStyle(fontSize: 12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 0,
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
        );
      }).toList(),
    );
  }
}
