///위치 기반 정보호출을 위한 클래스 선언

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List<dynamic> locationList = [];
List<dynamic> foodList = [];
List<dynamic> tourList = [];
List<dynamic> sleepList = [];
bool isInfoLoading = false;

//위치기반 정보 api 호출받아서 넣을 모델클래스 선언
class LocationData {
  final String title;
  final String address;
  final String imageUrl;
  final double dist;
  final double mapX;
  final double mapY;
  final String contentId;
  final String contentTypeId;
  final Key itemKey;

  LocationData({
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.dist,
    required this.mapX,
    required this.mapY,
    required this.contentId,
    required this.contentTypeId,
    required this.itemKey,
  });
}

/// 지역 관광지 리스트를 가져올거임
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
            itemKey: ValueKey(item),
          ),
        );

        if (item['contenttypeid'] == "32") {
          debugPrint("${item['title']}은 숙소다.");
          sleepList.add(
            LocationData(
              title: item['title'],
              address: item['addr1'],
              imageUrl: item['firstimage'],
              contentId: item['contentid'] ?? "",
              contentTypeId: item['contenttypeid'] ?? "",
              dist: double.parse(item['dist']),
              mapX: double.parse(item['mapx'] ?? "0"),
              mapY: double.parse(item['mapy'] ?? "0"),
              itemKey: ValueKey(item),
            ),
          );
        } else if (item['contenttypeid'] == "39") {
          debugPrint("${item['title']}은 음식점이다.");
          foodList.add(
            LocationData(
              title: item['title'],
              address: item['addr1'],
              imageUrl: item['firstimage'],
              contentId: item['contentid'] ?? "",
              contentTypeId: item['contenttypeid'] ?? "",
              dist: double.parse(item['dist']),
              mapX: double.parse(item['mapx'] ?? "0"),
              mapY: double.parse(item['mapy'] ?? "0"),
              itemKey: ValueKey(item),
            ),
          );
        } else {
          tourList.add(
            LocationData(
              title: item['title'],
              address: item['addr1'],
              imageUrl: item['firstimage'],
              contentId: item['contentid'] ?? "",
              contentTypeId: item['contenttypeid'] ?? "",
              dist: double.parse(item['dist']),
              mapX: double.parse(item['mapx'] ?? "0"),
              mapY: double.parse(item['mapy'] ?? "0"),
              itemKey: ValueKey(item),
            ),
          );
        }

        // debugPrint(
        //     "${item['title']},${item['addr1']},${item['contentid']},${item['contenttypeid']},${item['dist']},${item['mapx']},${item['mapy']},");
      }
    }
  } else {
    // 요청이 실패하면 오류를 출력
    throw Exception('Failed to load data');
  }
}

///지역의 구체적 정보를 가져올거임.
// HTTP GET 요청을 수행하고 데이터를 가져오는 함수
Future<String> getDetailInfo(apiUrl) async {
  try {
    debugPrint("요청해쪔.. $apiUrl");

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // 요청이 성공하면 JSON 데이터를 파싱하여 data 변수에 저장
      isInfoLoading = false;

      final jsonData = json.decode(utf8.decode(response.bodyBytes)); // 인코딩 처리

      if (jsonData['response']['body']["numOfRows"] == 0) {
        // 검색 결과가 없는 경우
        return "상세정보가 없습니다.";
      } else {
        final value =
            jsonData['response']['body']['items']['item'][0]['overview'];
        // .replaceAll('<br />', '\n'); // <br> 태그를 줄 바꿈 문자로 대체
        // .replaceAll(RegExp(r'<[^>]*>'), ''); // HTML 태그 제거;
        debugPrint("상세정보 ----- \n$value");
        return value;
      }
    } else {
      // 요청이 실패하면 오류를 출력
      return "상세정보를 불러오는데 실패했습니다.";
      // throw Exception('Failed to load data');
    }
  } catch (e) {
    debugPrint("예외갔쪔.");

    return "상세정보를 불러오는데 실패했습니다.";
  }
}
