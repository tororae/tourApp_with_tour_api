import 'package:flutter/material.dart';
import 'package:tour_with_tourapi/screen/main_screen.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

bool _isSplashClicked = false;

//Splash 화면 실행 후 실행되는 타이머. 2초 후 메인화면으로 진입.
//만약 클릭하여 화면을 넘어갔을 시, 이미 넘어간것을 확인하고 아무 조치를 취하지않음.
void _goMainPageTimer(context) {
  Future.delayed(
    const Duration(milliseconds: 2000),
    () {
      if (!_isSplashClicked) {
        _goMainPage(context);
      } else {
        debugPrint("페이지는 이미 넘어갔다.");
      }
    },
  );
}

//2초 후 or 클릭시 메인 화면으로 넘어가는 함수
void _goMainPage(context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MainScreen(),
    ),
  );
}

//메인 화면으로 넘어가기 전 스플래시 화면임.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _goMainPageTimer(context);

    return Scaffold(
      //클릭시 화면 넘어가는 기능.
      body: GestureDetector(
        onTap: () {
          _goMainPage(context);
          _isSplashClicked = true;
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                //color는 theme.dart에 선언되어있음.
                mainColor,
                subColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: const Image(
            image: AssetImage("lib/assets/splash.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }
}
