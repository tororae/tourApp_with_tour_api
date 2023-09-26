import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

List<Map<String, dynamic>> jsonData = [];
bool isLoading = false;

Future<Position> getCurrentLocation(context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('위치 서비스를 활성화해주세요.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    throw Exception('위치 접근 권한을 허용해주세요.');
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw Exception('위치 접근 권한을 허용해주세요.');
    }
  }

  Position position = await Geolocator.getCurrentPosition();

  debugPrint(
      "내 위치정보를 뿌린다.\n$currentLatitude,$currentLongitude\ntimestamp : ${position.timestamp}\naccuracy : ${position.accuracy}\naltitude : ${position.altitude}\nheading : ${position.heading}\nspeed : ${position.speed}\nspeedAccuracy : ${position.speedAccuracy}\n끝났다.");
  debugPrint("타임스탬프 : ${DateTime.timestamp()}");

  return position;
}

/// 좌표를 통한 거리 계산 함수
///
///
String calculateDistance({
  required double latStart,
  required double lngStart,
  required double latEnd,
  required double lngEnd,
}) {
  var r = 6371.0; // The average radius of Earth in kilometers
  var pi1 = latStart * pi / 180;
  var pi2 = latEnd * pi / 180;
  var deltaLambda = (lngEnd - lngStart) * pi / 180;

  var x = deltaLambda * cos((pi1 + pi2) / 2);
  var y = (pi2 - pi1);
  var z = sqrt(x * x + y * y) * r;

  debugPrint(
      "$latStart,$lngStart 그리고 $latEnd, $lngEnd로 간다.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

  debugPrint("${(z).toStringAsFixed(3)} km");
  return (z).toStringAsFixed(3);
}
