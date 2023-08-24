// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tour_with_tourapi/screen/schedule_screen.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

List test = <Widget>[
  ScreenNotice(pageInfo: "홈 화면은 개발 진행중입니다."),
  ScheduleScreen(),
  ScreenNotice(pageInfo: "테마 코스 화면은 개발 진행중입니다."),
  ScreenNotice(pageInfo: "주변 보기 화면은 개발 진행중입니다."),
  ScreenNotice(pageInfo: "내 설정 화면은 개발 진행중입니다."),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      debugPrint("$index가 선택됨.");
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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
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
          backgroundColor: mainColor,
          fixedColor: Colors.white,
          unselectedItemColor: Colors.white54,
        ),
      ),
    );
  }

  BottomNavigationBarItem myNavigationItem(
      {required String imagePath, required String labelText}) {
    return BottomNavigationBarItem(
        icon: Image(
          image: AssetImage(
            imagePath,
          ),
          height: 30,
          alignment: Alignment.topCenter,
          color: Colors.white54,
        ),
        activeIcon: Image(
          height: 30,
          alignment: Alignment.topCenter,
          image: AssetImage(imagePath),
        ),
        label: labelText);
  }
}

final class ScreenNotice extends StatelessWidget {
  const ScreenNotice({required this.pageInfo, super.key});
  final String pageInfo;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(pageInfo));
  }
}
