import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// const String apiUrl =
//     "https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=p7lOrWvzLtnkrtjd%2Bq8KlJxffMsCCQQpgjq9o8Hi7Lo8aZrtnjYn9vPepxCYPudDUPTtGbQfsjfBI%2BAmSAx4lQ%3D%3D&numOfRows=20&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json&listYN=Y&arrange=A&mapX=126.981611&mapY=37.568477&radius=1000";

List<dynamic> data = [];

// HTTP GET 요청을 수행하고 데이터를 가져오는 함수
Future<void> getLocationBasedData(apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    // 요청이 성공하면 JSON 데이터를 파싱하여 data 변수에 저장
    data = json.decode(response.body)["response"]["body"]["items"]["item"];
    debugPrint(response.body);
  } else {
    // 요청이 실패하면 오류를 출력
    throw Exception('Failed to load data');
  }
}
