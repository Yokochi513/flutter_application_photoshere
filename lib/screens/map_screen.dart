import 'package:flutter/material.dart';
import 'package:flutter_application_photoshere/widgets/post_maker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '/services/location_service.dart';
import '/widgets/post_form_sheet.dart';
import '/widgets/post_detail_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentPos;
  LatLng? _tappedPos;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadLocation();
    loadPost();
  }

  Future<void> _loadLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPos = LatLng(position.latitude, position.longitude);
        setState(() {});
        _mapController.move(_currentPos!, 14.0);
      });
    }
  }

  Future<void> loadPost() async {
    _posts = await PostService.fetchPosts();
    setState(() {});
  }

  void _openPostForm(LatLng pos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PostFormSheet(pos: pos),
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
              initialCenter: const LatLng(35.681236, 139.767125),
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // 全ての操作を許可
              ),
              onTap: (_, latlng) {
                setState(() => _tappedPos = latlng);
                _openPostForm(latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              // 現在地の表示
              if (_currentPos != null) ...[
                CircleLayer(circles: [
                  CircleMarker(
                    point: _currentPos!,
                    radius: 40,
                    color: Colors.orange.withOpacity(0.25),
                    borderStrokeWidth: 1,
                    borderColor: Colors.orange.withOpacity(0.6),
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
                            color: Colors.orange.withOpacity(0.6),
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
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoom_in",
                    mini: true,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18),
                        Text("拡大", style: TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // zoom out
                  FloatingActionButton(
                    heroTag: "zoom_out",
                    mini: true,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove, size: 18),
                        Text("縮小", style: TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 現在地へ移動
                  FloatingActionButton(
                    heroTag: "go_my_location",
                    mini: true,
                    onPressed: () {
                      if (_currentPos != null) {
                        _mapController.move(_currentPos!, 14.0);
                      }
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.my_location, size: 18),
                        Text("現在地", style: TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
