// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

Position getPosition = currentPosition ??
    Position(
      latitude: 37.715133,
      longitude: 126.734086,
      timestamp: DateTime.timestamp(),
      accuracy: 15.163000106811523,
      altitude: 34.30000305175781,
      heading: 32.578853607177734,
      speed: 0.12078452110290527,
      speedAccuracy: 0,
    );

NaverMap naverMapTest() {
  debugPrint("위도 : ${getPosition.latitude}, 경도 : ${getPosition.longitude}");
  return NaverMap(
    options: NaverMapViewOptions(
      initialCameraPosition: NCameraPosition(
        target: NLatLng(getPosition.latitude, getPosition.longitude),
        zoom: 10,
        bearing: 0,
        tilt: 0,
      ),
    ),
    onMapReady: (controller) {
      debugPrint("네이버 맵 로딩됨!");
    },
  );
}
