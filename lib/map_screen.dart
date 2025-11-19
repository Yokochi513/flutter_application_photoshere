import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentPosition; // ← 現在地
  LatLng? _tappedPosition; // ← タップ地点
  File? _selectedImage; // ← 写真

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効か確認
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置情報サービスが無効な場合、エラーメッセージを表示
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 権限が拒否された場合、エラーメッセージを表示
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 永久に拒否された場合、エラーメッセージを表示
      print('Location permissions are permanently denied.');
      return;
    }

    // 現在位置を取得
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // 地図の中心を現在位置に移動
    _mapController.move(_currentPosition!, 14.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("撮影場所マップ")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(35.681236, 139.767125),
          initialZoom: 14.0,
          onTap: (tapPos, latlng) {
            setState(() {
              _tappedPosition = latlng;
              _selectedImage = null; // 毎回リセット
            });

            _showPostForm(latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: "com.example.app",
          ),

          /// ★ 現在地マーカー
          if (_currentPosition != null) ...[
            // 精度円（青の薄いサークル）
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _currentPosition!,
                  color: Colors.blue.withOpacity(0.2), // 薄い青
                  borderStrokeWidth: 1,
                  borderColor: Colors.blue.withOpacity(0.5),
                  radius: 40, // 半径（メートルではなく px）
                ),
              ],
            ),

            // 中心の現在地マーカー（濃い青丸）
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition!,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          /// ★ タップ地点マーカー
          if (_tappedPosition != null) ...[
            MarkerLayer(
              markers: [
                Marker(
                  point: _tappedPosition!,
                  width: 50,
                  height: 50,
                  child: const Icon(Icons.place, color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// -------------------------------------------------------
  ///  投稿フォーム BottomSheet（写真アップロード必須）
  /// -------------------------------------------------------
  void _showPostForm(LatLng pos) {
    TextEditingController titleCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage() async {
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                setModalState(() {
                  _selectedImage = File(image.path);
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("投稿フォーム",
                        style: Theme.of(context).textTheme.headline6),

                    const SizedBox(height: 12),
                    Text("緯度: ${pos.latitude}"),
                    Text("経度: ${pos.longitude}"),

                    const SizedBox(height: 20),

                    /// タイトル
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                          labelText: "タイトル", border: OutlineInputBorder()),
                    ),

                    const SizedBox(height: 12),

                    /// 説明
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                          labelText: "説明", border: OutlineInputBorder()),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),

                    /// --------------------------------
                    /// 📸 写真アップロード（必須）
                    /// --------------------------------
                    Text("写真（必須）",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[400])),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage == null
                            ? const Center(
                                child: Text("タップして写真を選択"),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// --------------------------------
                    /// 投稿ボタン
                    /// --------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text("投稿する"),
                        onPressed: () {
                          if (_selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("写真は必須です"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // ここで DB / API などに保存処理を書く
                          print("投稿データ:");
                          print("場所: $pos");
                          print("タイトル: ${titleCtrl.text}");
                          print("説明: ${descCtrl.text}");
                          print("写真パス: ${_selectedImage!.path}");

                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
