import 'package:flutter/material.dart';

class MapControlButtons extends StatelessWidget {
  // ズームインボタンのコールバック
  final VoidCallback onZoomIn;
  // ズームアウトボタンのコールバック
  final VoidCallback onZoomOut;
  // 現在地に移動するボタンのコールバック
  final VoidCallback onGoToMyLocation;

  const MapControlButtons({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGoToMyLocation,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.8 * 255).round()), // 背景の透明度を設定
        borderRadius: BorderRadius.circular(12), // 角を丸くする
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // 影の色
            blurRadius: 8, // 影のぼかし半径
          ),
        ],
      ),
      child: Column(
        children: [
          // ズームインボタン
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: onZoomIn,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18), // プラスアイコン
                Text("拡大", style: TextStyle(fontSize: 9)), // ラベル
              ],
            ),
          ),
          const SizedBox(height: 10),
          // ズームアウトボタン
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: onZoomOut,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove, size: 18), // マイナスアイコン
                Text("縮小", style: TextStyle(fontSize: 9)), // ラベル
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 現在地に移動するボタン
          FloatingActionButton(
            heroTag: "go_my_location",
            mini: true,
            onPressed: onGoToMyLocation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.my_location, size: 18), // 現在地アイコン
                Text("現在地", style: TextStyle(fontSize: 9)), // ラベル
              ],
            ),
          ),
        ],
      ),
    );
  }
}
