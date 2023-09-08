import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tour_with_tourapi/main.dart';
import 'package:tour_with_tourapi/screen/naver_map_func.dart';
import 'package:tour_with_tourapi/screen/schedule_screen.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

List navigationItems = <Widget>[
  const ScreenNotice(pageInfo: "홈 화면은 개발 진행중입니다."),
  const ScheduleScreen(),
  const ScreenNotice(pageInfo: "테마 코스 화면은 개발 진행중입니다."),
  const ScreenNotice(pageInfo: "주변 보기 화면은 개발 진행중입니다."),
  const ScreenNotice(pageInfo: "내 설정 화면은 개발 진행중입니다."),
];

bool _isInitialized = false; // 최초 실행 여부를 나타내는 변수

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  int page = 1;
  @override
  void initState() {
    super.initState();
    debugPrint("권한요청 간다.");
    debugPrint("초기화 여부 : $_isInitialized.");

    if (!_isInitialized) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);

      //이를 통해서 내 현재위치를 스케쥴로 전달.
      getCurrentLocation(context).then(
        (value) {
          //현재 위치에 값 저장.
          currentPosition = value;
          //포지션의 위도경도 주소로 변환 후 받아서 프로바이더에 전달.
          getAddress(context, "${value.longitude},${value.latitude}")
              .then((value) => locationProvider.updateText(value));
        },
      );
      _isInitialized = true; // 최초 실행 후 변수 값을 변경하여 다음에는 실행되지 않도록 함
    }
  }

  // final ScrollController _scrollController = ScrollController();

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
        body: navigationItems.elementAt(_selectedIndex),

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
        child: Column(
      children: [
        Text(
          pageInfo,
          style: const TextStyle(color: mainColor, fontSize: 30),
        ),
      ],
    ));
  }
}
