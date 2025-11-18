import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition; // ユーザーの現在位置を格納する変数

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
      appBar: AppBar(title: const Text('撮影場所マップ (OSM)')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(35.681236, 139.767125), // v7 ではこれ
          initialZoom: 14.0, // v7 ではこれ
          // 必要ならタップなどのイベントも設定可能
          onTap: (tapPosition, latlng) {
            // 地図をタップしたときに latlng が取得できる
            print("Tapped at $latlng");
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName:
                'com.example.app', // 任意。ドキュメント例にもある。:contentReference[oaicite:3]{index=3}
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition ?? LatLng(35.681236, 139.767125),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    print("マーカーがタップされた！");
                  },
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
