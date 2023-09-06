import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tour_with_tourapi/screen/naver_map_func.dart';

const Color mainColor = Color(0xff693FDD);
const Color subColor = Color(0xff523EBF);
const Color backColor = Color(0xffF6F8FA);

Position? currentPosition;

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
      "내 위치정보를 뿌린다.\n$currentPosition\ntimestamp : ${position.timestamp}\naccuracy : ${position.accuracy}\naltitude : ${position.altitude}\nheading : ${position.heading}\nspeed : ${position.speed}\nspeedAccuracy : ${position.speedAccuracy}\n끝났다.");
  debugPrint("타임스탬프 : ${DateTime.timestamp()}");

  return position;
  // return getAddress(context, "${position.longitude},${position.latitude}"); //주소를 반환하는데 이로 인해 위치값을 전달 못하게 됨.
  //함수 분리 필요.
}

  // Future<void> fetchData() async {
  //   if (isLoading) return;

  //     isLoading = true;

  //   var latitude = currentPosition?.latitude ?? 0.0;
  //   var longitude = currentPosition?.longitude ?? 0.0;

  //   var url = Uri.parse(
  //       'https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=p7lOrWvzLtnkrtjd%2Bq8KlJxffMsCCQQpgjq9o8Hi7Lo8aZrtnjYn9vPepxCYPudDUPTtGbQfsjfBI%2BAmSAx4lQ%3D%3D&numOfRows=10&MobileOS=ETC&MobileApp=AppTest&_type=json&listYN=Y&arrange=C&mapX=$longitude&mapY=$latitude&radius=1000&contentTypeId=32&pageNo=$page');

  //   var res = await http.get(url);

  //   if (res.statusCode == 200) {
  //     var decodedData = jsonDecode(utf8.decode(res.bodyBytes));

  //     if (decodedData['response']['header']['resultCode'] == "0000") {
  //       var itemList = decodedData['response']['body']['items']['item'];

  //       if (itemList is List) {
  //         var itemListTyped = itemList.cast<Map<String, dynamic>>();

  //           jsonData.addAll(itemListTyped);
  //           isLoading = false;
  //       } else {
  //         throw Exception('데이터 형식이 올바르지 않습니다.');
  //       }
  //     } else {
  //       throw Exception('데이터를 불러오는 데 실패했습니다.');
  //     }
  //   } else {
  //     throw Exception('데이터를 불러오는 데 실패했습니다.');
  //   }
  // }
