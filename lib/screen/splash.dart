import 'package:flutter/material.dart';
import 'package:tour_with_tourapi/screen/main_screen.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

bool _isSplashClicked = false;

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

void _goMainPage(context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MainScreen(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _goMainPageTimer(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _goMainPage(context);
          _isSplashClicked = true;
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
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
