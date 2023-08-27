import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tour_with_tourapi/screen/schedule_screen.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

List test = <Widget>[
  const ScreenNotice(pageInfo: "홈 화면은 개발 진행중입니다."),
  const ScheduleScreen(),
  const ScreenNotice(pageInfo: "테마 코스 화면은 개발 진행중입니다."),
  const ScreenNotice(pageInfo: "주변 보기 화면은 개발 진행중입니다."),
  const ScreenNotice(pageInfo: "내 설정 화면은 개발 진행중입니다."),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> jsonData = [];
  bool isLoading = false;
  int page = 1;
  Position? currentPosition;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint("권한요청 간다.");
    getCurrentLocation();
  }

  // final ScrollController _scrollController = ScrollController();

  Future<void> getCurrentLocation() async {
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
    setState(() {
      currentPosition = position;
      debugPrint("$currentPosition");
    });

    fetchData();
  }

  Future<void> fetchData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    var latitude = currentPosition?.latitude ?? 0.0;
    var longitude = currentPosition?.longitude ?? 0.0;

    var url = Uri.parse(
        'https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=p7lOrWvzLtnkrtjd%2Bq8KlJxffMsCCQQpgjq9o8Hi7Lo8aZrtnjYn9vPepxCYPudDUPTtGbQfsjfBI%2BAmSAx4lQ%3D%3D&numOfRows=10&MobileOS=ETC&MobileApp=AppTest&_type=json&listYN=Y&arrange=C&mapX=$longitude&mapY=$latitude&radius=1000&contentTypeId=32&pageNo=$page');

    var res = await http.get(url);

    if (res.statusCode == 200) {
      var decodedData = jsonDecode(utf8.decode(res.bodyBytes));

      if (decodedData['response']['header']['resultCode'] == "0000") {
        var itemList = decodedData['response']['body']['items']['item'];

        if (itemList is List) {
          var itemListTyped = itemList.cast<Map<String, dynamic>>();

          setState(() {
            jsonData.addAll(itemListTyped);
            page++;
            isLoading = false;
          });
        } else {
          throw Exception('데이터 형식이 올바르지 않습니다.');
        }
      } else {
        throw Exception('데이터를 불러오는 데 실패했습니다.');
      }
    } else {
      throw Exception('데이터를 불러오는 데 실패했습니다.');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool backButtonChk = false; //뒤로가기 클릭여부 파악
    ///뒤로가기 클릭시 Splash 화면으로 넘어가는것을 방지
    ///더불어 2초 안에 2번 뒤로가기를 누르면 앱 종료 기능 추가
    return WillPopScope(
      onWillPop: () async {
        if (backButtonChk == false) {
          Fluttertoast.showToast(
            msg: "한번 더 뒤로가기를 클릭하여 앱을 종료합니다.",
          );
          backButtonChk = true; //true로 설정한 후 뒤로가기 누르면 꺼짐
          Future.delayed(
            const Duration(milliseconds: 2000),
            () {
              backButtonChk = false;
            },
          );
        } else {
          SystemNavigator.pop(); //앱 종료함수
        }

        return false;
      },
      child: Scaffold(
        body: test.elementAt(_selectedIndex),

        //NavigationBar로 교체함. 근데 글자 색 바꾸는 옵션이 없는 듯 함.
        bottomNavigationBar: NavigationBar(
          indicatorColor: Colors.white,
          destinations: [
            myNavigationItem(
                imagePath: "lib/assets/img1_home.png", labelText: "홈"),
            myNavigationItem(
                imagePath: "lib/assets/img2_schedule.png", labelText: "스케쥴"),
            myNavigationItem(
                imagePath: "lib/assets/img3_themecourse.png",
                labelText: "테마코스"),
            myNavigationItem(
                imagePath: "lib/assets/img4_around.png", labelText: "주변보기"),
            myNavigationItem(
                imagePath: "lib/assets/img5_setting.png", labelText: "내 설정"),
          ],
          onDestinationSelected: _onItemTapped,
          selectedIndex: _selectedIndex,
          backgroundColor: mainColor,
        ),
      ),
    );
  }

  NavigationDestination myNavigationItem(
      {required String imagePath, required String labelText}) {
    return NavigationDestination(
      selectedIcon: Image(
        image: AssetImage(
          imagePath,
        ),
        color: mainColor,
        alignment: Alignment.topCenter,
      ),
      icon: Image(
        image: AssetImage(
          imagePath,
        ),
        alignment: Alignment.topCenter,
      ),
      label: labelText,
    );
  }
}

final class ScreenNotice extends StatelessWidget {
  const ScreenNotice({required this.pageInfo, super.key});
  final String pageInfo;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      pageInfo,
      style: const TextStyle(color: mainColor, fontSize: 30),
    ));
  }
}
