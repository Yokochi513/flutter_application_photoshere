import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '/services/location_service.dart';
import '/widgets/post_form_sheet.dart';

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
        title: const Text('撮影場所マップ'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(35.681236, 139.767125),
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
                    color: Colors.blue.withOpacity(0.2),
                    borderStrokeWidth: 1,
                    borderColor: Colors.blue.withOpacity(0.5),
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    width: 20,
                    height: 20,
                    point: _currentPos!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
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
                          builder: (_) => AlertDialog(
                            title: Text(post.title),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 300),
                                  child: Image.network(
                                    post.imageUrls.isNotEmpty
                                        ? post.imageUrls[0]
                                        : '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(post.description),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('閉じる'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.black,
                        size: 40,
                        shadows: [Shadow(color: Colors.white, blurRadius: 10)],
                      ),
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
                  child: const Icon(Icons.add),
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
                  child: const Icon(Icons.remove),
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
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
