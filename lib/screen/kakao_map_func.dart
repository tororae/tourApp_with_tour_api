import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:tour_with_tourapi/main.dart';
import 'package:tour_with_tourapi/screen/location_base_info.dart';
import 'package:tour_with_tourapi/setting/secret.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

Set<Marker> markers = {}; //상세정보 보기에서 마커.
String areaName = ""; //동변환 주소값 담기는 변수

//여행시 목적지들 줄 긋기 위한 배열.
List<LatLng> tourLine = [];

//여행 최종 목록 지도에 마커와 라인 긋는 함수.
Widget kakaoMapTourList(context) {
  return KakaoMap(
    onMapCreated: ((controller) async {
      markers.clear();
      markers.add(Marker(
        markerId: UniqueKey().toString(),
        latLng: LatLng(finalTourList[0].mapY, finalTourList[0].mapX),
      ));
    }),
    markers: markers.toList(),
    center: LatLng(finalTourList[0].mapY, finalTourList[0].mapX),
  );
}

//여행일정 설정중 지도 호출시 나오는 화면.
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
    },
  );
}

//좌표 받아와서 동변환 해줌.
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
