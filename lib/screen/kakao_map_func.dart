import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:tour_with_tourapi/main.dart';
import 'package:tour_with_tourapi/setting/secret.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

Set<Marker> markers = {};
String areaName = ""; //동변환 주소값 담기는 변수

Widget kakaoMapClickEvent(context) {
  return KakaoMap(
    center: LatLng(currentLatitude, currentLongitude),
    onMapTap: (latLng) {
      showDialog(
        context: context,
        builder: (context) {
          return chkPickLocation(context,
              longitude: latLng.longitude, latitude: latLng.latitude);
        },
      );
      getAddress(context,
          latitude: latLng.latitude, longitude: latLng.longitude);
      debugPrint("너 설마?");
    },
  );
}

Future<String> getAddress(context,
    {required double longitude, required double latitude}) async {
  const String apiUrl =
      "https://dapi.kakao.com/v2/local/geo/coord2address.json?input_coord=WGS84&x=";
  const String apiUrl2 = "&y=";
  debugPrint("$longitude, $latitude 와 함께 getAddress 실행.");
  debugPrint("$apiUrl$longitude$apiUrl2$latitude");
  final locationProvider =
      Provider.of<LocationProvider>(context, listen: false);
  // try {
  final response = await http.get(
    Uri.parse("$apiUrl$longitude$apiUrl2$latitude"),
    headers: {
      'Authorization': 'KakaoAK $kakaoMapRestApiKey',
    },
  );
  final decodedResponse = json.decode(response.body);

  // // JSON 응답을 파싱하여 주소 정보 추출
  debugPrint(response.body);
  if (decodedResponse['documents'].isEmpty) {
    debugPrint("비었구만. 체크완료");
    locationProvider.updatePopupText("주소가 없는 장소에요.");
    return "주소가 없는 장소에요.";
  }
  final document = decodedResponse['documents'][0];
  final address = document['address'];

  debugPrint("걍주소 - $address ");

  locationProvider.updatePopupText(
      "${address['region_1depth_name']} ${address['region_2depth_name']} ${address['region_3depth_name']}");
  return "${address['region_1depth_name']} ${address['region_2depth_name']} ${address['region_3depth_name']}";
}

///좌표 동변환 함수
Future<String> getAddressNaver(context, position) async {
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
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (data["status"]["code"] == 0) {
      final area = data["results"][0]["region"];
      areaName =
          "${area["area1"]["name"]} ${area["area2"]["name"]} ${area["area3"]["name"]} ${area["area4"]["name"]}";
      debugPrint("$areaName은 출력됨.");

      locationProvider.updatePopupText(areaName);
      return areaName;
    } else {
      locationProvider.updatePopupText("주소가 없는 장소에요");

      return "주소가 없는 장소에요";
    }
  } else {
    // 요청 실패 처리
    debugPrint("Failed to load data: ${response.statusCode}");
    return "";
  }
}

///지도 클릭시 팝업화면
chkPickLocation(context, {required longitude, required latitude}) {
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
              locationProvider.popupLocation,
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
            currentLongitude = longitude;
            currentLatitude = latitude;
            // currentPosition = position;
            debugPrint("..\n$latitude,$longitude 대입 완료\n..");
            locationProvider.updateText(locationProvider.popupLocation);
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
