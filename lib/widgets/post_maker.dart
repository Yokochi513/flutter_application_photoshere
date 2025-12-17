import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // ← 地図用

/// 🔥 光のゆらぎ付きマーカーウィジェット
class PostMarker extends StatefulWidget {
  final MapController mapController;

  const PostMarker({super.key, required this.mapController});

  @override
  State<PostMarker> createState() => _PostMarkerState();
}

class _PostMarkerState extends State<PostMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); // ← 光がふわっと脈動
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final zoom = widget.mapController.camera.zoom;
        final scale = (zoom / 14.0).clamp(0.8, 2.2);

        /// 0.9〜1.2で揺らぐ → 光の呼吸を表現
        final pulse = 0.9 + _controller.value * 0.3;

        return Stack(
          alignment: Alignment.center,
          children: [
            // 🔆 外側に広がる柔らかい輪
            Container(
              width: (32 * scale * pulse).clamp(10, double.infinity),
              height: (32 * scale * pulse).clamp(10, double.infinity),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withAlpha((0.95 * 255).round()),
                    Colors.yellowAccent.withAlpha((0.55 * 255).round()),
                    Colors.amber.withAlpha((0.24 * 255).round()),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.32, 0.68, 1.0],
                ),
              ),
            ),

            // 🔥 表現力向上：第二層 光の余韻（薄く重ねると綺麗）
            Container(
              width: (48 * scale * pulse).clamp(14, double.infinity),
              height: (48 * scale * pulse).clamp(14, double.infinity),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withAlpha((0.10 * pulse * 255).round()),
              ),
            ),

            // 🌕 中心の核（最も明るい点）
            Container(
              width: (12 * scale).clamp(6, double.infinity),
              height: (12 * scale).clamp(6, double.infinity),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber.shade700,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withAlpha((0.7 * pulse * 255).round()),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
