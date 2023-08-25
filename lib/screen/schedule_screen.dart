import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tour_with_tourapi/setting/theme.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

DateTime _temporaryDate = DateTime.now();

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _startDate = DateTime.now();

  dateApply(bool isStart) {
    setState(() {
      _startDate = _temporaryDate;
      debugPrint("$_temporaryDate 는 호출됨.");
    });
  }

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
            const Text("드랍박스 예정. 서울 등 클릭시 상세 지역 추가할지 고민중"),
            const SizedBox(height: 20),
            scheduleTitleText(titleText: "일정을 정해주세요."),
            const SizedBox(height: 10),
            const Text(
              "출발 일자",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => datePicker(
                context: context,
                selectedDate: _startDate,
                scheduleApply: dateApply,
                isStart: true,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: mainColor),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Text(
                  DateFormat("yyyy년 MM월 dd일").format(_startDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void datePicker(
      {context,
      required DateTime selectedDate,
      required Function scheduleApply,
      required bool isStart}) {
    _temporaryDate = selectedDate;
    showDialog(
      barrierDismissible: false, //버튼으로만 종료 가능해짐.
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 400,
                child: CupertinoDatePicker(
                  initialDateTime: _startDate,
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  // This shows day of week alongside day of month
                  showDayOfWeek: true,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => _startDate = newDate);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _temporaryDate = selectedDate;
                      debugPrint("$selectedDate 와 $_temporaryDate");
                      dateApply(isStart);
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        focusedBorder: const OutlineInputBorder(
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
