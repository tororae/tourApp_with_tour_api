import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// const String apiUrl =
//     "https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=p7lOrWvzLtnkrtjd%2Bq8KlJxffMsCCQQpgjq9o8Hi7Lo8aZrtnjYn9vPepxCYPudDUPTtGbQfsjfBI%2BAmSAx4lQ%3D%3D&numOfRows=20&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json&listYN=Y&arrange=A&mapX=126.981611&mapY=37.568477&radius=1000";

List<dynamic> locationList = [];

class LocationData {
  final String title;
  final String address;
  final String imageUrl;

  LocationData(
      {required this.title, required this.address, required this.imageUrl});
}

// HTTP GET 요청을 수행하고 데이터를 가져오는 함수
Future<void> getLocationBasedData(apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));
  locationList.clear(); //리스트를 초기화하고 다시 로딩하기 위함.
  debugPrint("----------지역기반 관광지 호출결과");
  debugPrint("----------지역기반 관광지 호출결과\n$response");
  if (response.statusCode == 200) {
    // 요청이 성공하면 JSON 데이터를 파싱하여 data 변수에 저장

    final jsonData = json.decode(utf8.decode(response.bodyBytes)); // 인코딩 처리

    if (jsonData['response']['body']["numOfRows"] == 0) {
      // 검색 결과가 없는 경우
    } else {
      final items = jsonData['response']['body']['items']['item'];

      for (var item in items) {
        locationList.add(LocationData(
          title: item['title'],
          address: item['addr1'],
          imageUrl: item['firstimage'],
        ));
      }
    }
  } else {
    // 요청이 실패하면 오류를 출력
    throw Exception('Failed to load data');
  }
}
