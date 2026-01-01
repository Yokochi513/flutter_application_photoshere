import 'package:flutter/material.dart';
import 'package:flutter_application_photoshere/widgets/post_maker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '/services/location_service.dart';
import '/widgets/post_form_sheet.dart';
import '/widgets/post_detail_dialog.dart';
import '../widgets/map_control_buttons.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentPos; // 現在地の座標を保持する変数
  LatLng? _tappedPos; // ユーザーがタップした位置の座標を保持する変数
  List<Post> _posts = []; // 投稿データのリスト

  @override
  void initState() {
    super.initState();
    _loadLocation(); // 現在地を取得する非同期処理を呼び出し
    loadPost(); // 投稿データを取得する非同期処理を呼び出し
  }

  Future<void> _loadLocation() async {
    final position = await LocationService.getCurrentLocation(); // 現在地を取得
    if (position != null) {
      setState(() {
        _currentPos = LatLng(position.latitude, position.longitude); // 現在地を設定
        setState(() {});
        _mapController.move(_currentPos!, 14.0); // マップを現在地に移動
      });
    }
  }

  Future<void> loadPost() async {
    _posts = await PostService.fetchPosts(); // 投稿データを取得
    setState(() {});
  }

  void _openPostForm(LatLng pos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PostFormSheet(pos: pos), // 投稿フォームを表示
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('ひかりの跡',
              style: TextStyle(
                  color: Colors.orange.shade600, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(35.681236, 139.767125), // 初期位置を設定
              initialZoom: 14.0, // 初期ズームレベルを設定
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // 全ての操作を許可
              ),
              onTap: (_, latlng) {
                setState(() => _tappedPos = latlng); // タップ位置を更新
                _openPostForm(latlng); // 投稿フォームを開く
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // タイルのURLテンプレート
                subdomains: const ['a', 'b', 'c'],
              ),
              // 現在地の表示
              if (_currentPos != null) ...[
                CircleLayer(circles: [
                  CircleMarker(
                    point: _currentPos!,
                    radius: 40,
                    color: Colors.orange.withAlpha((0.25 * 255).round()),
                    borderStrokeWidth: 1,
                    borderColor: Colors.orange.withAlpha((0.6 * 255).round()),
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    width: 20,
                    height: 20,
                    point: _currentPos!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Colors.white, Colors.orange],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withAlpha((0.6 * 255).round()),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  )
                ])
              ],

              // タップ位置の表示
              if (_tappedPos != null)
                MarkerLayer(markers: [
                  Marker(
                    width: 50,
                    height: 50,
                    point: _tappedPos!,
                    child: const Icon(
                      Icons.place,
                      color: Colors.red,
                      size: 40,
                    ),
                  )
                ]),

              // 投稿マーカーの表示
              MarkerLayer(
                markers: _posts.map((post) {
                  return Marker(
                    width: 50,
                    height: 50,
                    point: LatLng(post.latitude, post.longitude),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => PostDetailDialog(post: post),
                        );
                      },
                      child: PostMarker(mapController: _mapController),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ------------------
          // 右下にマップ操作ボタン
          // ------------------
          Positioned(
            bottom: 20,
            right: 20,
            child: MapControlButtons(
              onZoomIn: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1, // ズームイン
                );
              },
              onZoomOut: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1, // ズームアウト
                );
              },
              onGoToMyLocation: () {
                if (_currentPos != null) {
                  _mapController.move(_currentPos!, 14.0); // 現在地に移動
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
