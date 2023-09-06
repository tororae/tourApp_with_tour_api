// ignore: unused_import
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tour_with_tourapi/main.dart';
import 'package:tour_with_tourapi/setting/secret.dart';
import 'package:tour_with_tourapi/setting/theme.dart';
import 'package:provider/provider.dart';

String areaName = "";

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
  getPosition = currentPosition ??
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
      getAddress(context, "${latLng.longitude},${latLng.latitude}");
      showDialog(
        context: context,
        builder: (context) {
          return chkPickLocation(context, getPosition);
        },
      );
    },
  );
}

//동변환 함수

Future<String> getAddress(context, position) async {
  const String apiUrl =
      "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc";
  String coords = position; // 여기에 입력 좌표 값을 넣으세요
  const String orders = "legalcode"; // 여기에 변환 작업 이름 값을 넣으세요
  const String output = "json"; // 여기에 출력 형식 값을 넣으세요
  const String apiKeyId = naverMapApiKey;
  const String apiKeySecret = naverMapApiSecret;

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

    final area = data["results"][0]["region"];
    areaName =
        "${area["area1"]["name"]} ${area["area2"]["name"]} ${area["area3"]["name"]} ${area["area4"]["name"]}";
    debugPrint("$areaName은 출력됨.");
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.updatePopupText(areaName);
    return areaName;
  } else {
    // 요청 실패 처리
    debugPrint("Failed to load data: ${response.statusCode}");
    return "";
  }
}

chkPickLocation(context, position) {
  final locationProvider = Provider.of<LocationProvider>(context);

  return AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: mainColor,
              size: 19,
            ),
            Text(
              "여행 목적지 선택중..",
              style: TextStyle(
                color: mainColor,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.close,
            color: mainColor,
            size: 30,
          ),
        ),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: mainColor,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              locationProvider.popup_location,
              style: const TextStyle(
                  color: mainColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text("여기로 떠날까요?"),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
            locationProvider.updateText(areaName);
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              '네, 여기로 할래요.',
              style: TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: mainColor),
              borderRadius: BorderRadius.circular(
                5,
              ),
            ),
            child: const Text(
              '취소하고 나갈게요.',
              style: TextStyle(
                color: mainColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}
