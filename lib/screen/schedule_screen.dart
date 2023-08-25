import 'package:flutter/material.dart';
import 'package:tour_with_tourapi/setting/theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            scheduleTitleText(titleText: "여행의 테마를 입력해주세요."),
            const SizedBox(height: 10),
            scheduleTextField(hintText: "힐링/벚꽃놀이/산책"),
            const SizedBox(height: 20),
            scheduleTitleText(titleText: "어떤 지역을 여행하나요?"),
            Text("드랍박스 예정. 서울 등 클릭시 상세 지역 추가할지 고민중"),
            scheduleTitleText(titleText: "일정을 정해주세요."),
            Text("날짜/시간 선택기능 추가 예정"),
          ],
        ),
      ),
    );
  }

  ///스케쥴 화면에서 텍스트를 입력받는 컴포넌트.
  ///추후 공용으로 쓰이게 되면 이름 변경 가능성 있음.
  ///컨트롤러를 통한 값 연동에 대해 공부해야함.

  TextField scheduleTextField({required String hintText}) {
    return TextField(
      cursorColor: mainColor,
      decoration: InputDecoration(
        hintText: hintText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: mainColor,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: mainColor,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
    );
  }
}

///스케쥴 화면에서 활용하는 제목 컴포넌트
Text scheduleTitleText({required String titleText}) {
  return Text(
    titleText,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}
