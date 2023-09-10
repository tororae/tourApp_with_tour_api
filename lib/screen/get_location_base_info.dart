///위치 기반 정보호출을 위한 클래스 선언

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List<dynamic> locationList = [];

class LocationData {
  final String title;
  final String address;
  final String imageUrl;
  final double dist;
  final double mapX;
  final double mapY;
  final String contentId;
  final String contentTypeId;

  LocationData({
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.dist,
    required this.mapX,
    required this.mapY,
    required this.contentId,
    required this.contentTypeId,
  });
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
        locationList.add(
          LocationData(
            title: item['title'],
            address: item['addr1'],
            imageUrl: item['firstimage'],
            contentId: item['contentid'] ?? "",
            contentTypeId: item['contenttypeid'] ?? "",
            dist: double.parse(item['dist']),
            mapX: double.parse(item['mapx'] ?? "0"),
            mapY: double.parse(item['mapy'] ?? "0"),
          ),
        );
        debugPrint(
            "${item['title']},${item['addr1']},${item['contentid']},${item['contenttypeid']},${item['dist']},${item['mapx']},${item['mapy']},");
      }
    }
  } else {
    // 요청이 실패하면 오류를 출력
    throw Exception('Failed to load data');
  }
}
