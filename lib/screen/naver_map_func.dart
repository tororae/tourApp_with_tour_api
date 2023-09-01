// ignore: unused_import
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tour_with_tourapi/setting/secret.dart';
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

NaverMap naverMapTest(context) {
  debugPrint("위도 : ${getPosition.latitude}, 경도 : ${getPosition.longitude}");
  return NaverMap(
    options: NaverMapViewOptions(
      initialCameraPosition: NCameraPosition(
        target: NLatLng(getPosition.latitude, getPosition.longitude),
        zoom: 10,
        bearing: 0,
        tilt: 0,
      ),
      mapType: NMapType.basic,
      activeLayerGroups: [NLayerGroup.building, NLayerGroup.transit],
    ),
    onMapReady: (myMapController) {
      debugPrint("네이버 맵 로딩됨!");
    },
    onMapTapped: (point, latLng) {
      // Navigator.pop(context);
      debugPrint("${latLng.latitude}、${latLng.longitude}");
      getAddress("${latLng.longitude},${latLng.latitude}");
    },
  );
}

//동변환 함수
Future<void> getAddress(position) async {
  const String apiUrl =
      "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc";
  String coords = position; // 여기에 입력 좌표 값을 넣으세요
  const String orders = "legalcode"; // 여기에 변환 작업 이름 값을 넣으세요
  const String output = "json"; // 여기에 출력 형식 값을 넣으세요
  const String apiKeyId = naverMapApiKey;
  const String apiKeySecret = naverMapApiSecret;

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse("$apiUrl?coords=$coords&orders=$orders&output=$output"),
      headers: {
        "X-NCP-APIGW-API-KEY-ID": apiKeyId,
        "X-NCP-APIGW-API-KEY": apiKeySecret,
      },
    );

    if (response.statusCode == 200) {
      // JSON 응답 파싱
      final Map<String, dynamic> data = json.decode(response.body);
      debugPrint("Response Data: $data");
    } else {
      // 요청 실패 처리
      debugPrint("Failed to load data: ${response.statusCode}");
    }
  }

  fetchData();
}
