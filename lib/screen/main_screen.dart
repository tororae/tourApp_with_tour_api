// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
      child: const Scaffold(
        body: Center(
          child: Text("글자다 으왕"),
        ),
      ),
    );
  }
}
