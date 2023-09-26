import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tour_with_tourapi/main.dart';
import 'package:tour_with_tourapi/screen/kakao_map_func.dart';
import 'package:tour_with_tourapi/screen/list_schedule.dart';
import 'package:tour_with_tourapi/setting/secret.dart';
import 'package:tour_with_tourapi/setting/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

DateTime _temporaryDate = DateTime.now();

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController _searchRangeController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  dayApply(bool isStart) {
    setState(() {
      if (isStart) {
        _startDate = _temporaryDate;
        if (_startDate.difference(_endDate).inDays >= 1) {
          _endDate = _startDate;
        }
        Navigator.pop(context, 'OK');
      } else {
        if (_temporaryDate.difference(_startDate).inDays >= 0) {
          _endDate = _temporaryDate;
          Navigator.pop(context, 'OK');
        } else {
          Fluttertoast.showToast(
            msg: "출발 일자보다 빠르게 설정할 수 없습니다.",
          );
        }
      }
    });
  }

  timeApply(bool isStart) {
    setState(() {
      if (isStart) {
        _startDate = _temporaryDate;
        if (_startDate.difference(_endDate).inDays == 0) {
          _endDate = _startDate;
        }
        Navigator.pop(context, 'OK');
      } else {
        if (_temporaryDate.difference(_startDate).inMinutes >= 0) {
          _endDate = _temporaryDate;
          Navigator.pop(context, 'OK');
        } else {
          Fluttertoast.showToast(
            msg: "출발 일시보다 빠르게 설정할 수 없습니다.",
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    //검색범위 설정용 변수
    return Stack(
      children: [
        const Positioned.fill(
          child: Image(
            image: AssetImage(
              "lib/assets/background.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //키워드 기반 검색과 위치 기반 검색이 중복제공되지 않음.
                  //우선적으로 위치 기반을 위해 해당 기능 숨김처리.
                  // scheduleTitleText(titleText: "여행의 테마를 입력해주세요."),
                  // const SizedBox(height: 10),
                  // scheduleTextField(hintText: "힐링/벚꽃놀이/산책"),
                  // const SizedBox(height: 20),

                  scheduleTitleText(titleText: "어떤 지역을 여행하나요?"),
                  const SizedBox(height: 10),
                  const Text(
                    "현재 선택위치",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    locationProvider.text,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return kakaoMapClickEvent(context);
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: mainColor),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      child: const Text("지도 호출"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  scheduleTitleText(titleText: "검색 범위를 선택해주세요.\n(미터 단위)"),
                  const SizedBox(height: 10),

                  scheduleTextField(
                      hintText: "1000", controller: _searchRangeController),
                  const SizedBox(height: 20),
                  scheduleTitleText(titleText: "일정을 정해주세요."),
                  const SizedBox(height: 10),
                  //날짜선택부
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "출발 일자",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => datePicker(
                              context: context,
                              selectedDate: _startDate,
                              isStart: true,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
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
                      Column(
                        children: [
                          const Text(
                            "도착 일자",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => datePicker(
                              context: context,
                              selectedDate: _endDate,
                              isStart: false,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: mainColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                DateFormat("yyyy년 MM월 dd일").format(_endDate),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "출발 시간",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => timePicker(
                              context: context,
                              selectedDate: _startDate,
                              isStart: true,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: mainColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                DateFormat.Hm().format(_startDate),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "도착 시간",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => timePicker(
                              context: context,
                              selectedDate: _endDate,
                              isStart: false,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: mainColor),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                DateFormat.Hm().format(_endDate),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  GestureDetector(
                    onTap: () {
                      if (_searchRangeController.text == "") {
                        _searchRangeController.text = "1000";
                      }
                      debugPrint(
                          "경도 : $currentLongitude,위도 : $currentLatitude, ${_searchRangeController.text}범위로 검색.");
                      debugPrint(
                          "출발시간 : ${_startDate.year}년 ${_startDate.month}월 ${_startDate.day}일\n${_startDate.hour}시 ${_startDate.minute}분");
                      debugPrint(
                          "출발시간 : ${_endDate.year}년 ${_endDate.month}월 ${_endDate.day}일\n${_endDate.hour}시 ${_endDate.minute}분");
                      String url =
                          "$tourApiMainUrl$locationBased$tourApiKey${numOfRows}1000${pageNo}1$others$arrange $mapX$currentLongitude$mapY$currentLatitude$radius${_searchRangeController.text}";
                      debugPrint(url);
                      // getLocationBasedData(url);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleList(
                            apiUrl: url,
                            startDate: _startDate,
                            endDate: _endDate,
                          ),
                        ),
                      );
                    },
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          '추천여행지 목록보기',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

//쿠퍼티노 디자인의 날짜 선택기
  void datePicker({
    context,
    required DateTime selectedDate,
    required bool isStart,
  }) {
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
                  itemExtent: 40,
                  minimumYear: DateTime.now().year,
                  minimumDate: DateTime.now().subtract(
                    const Duration(minutes: 1),
                  ),
                  maximumYear: DateTime.now().year + 1,
                  initialDateTime: _temporaryDate,
                  mode: CupertinoDatePickerMode.date,
                  showDayOfWeek: true,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => _temporaryDate = newDate);
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
                      dayApply(isStart);
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

//쿠퍼티노 디자인의 시간 선택기
  void timePicker({
    context,
    required DateTime selectedDate,
    required bool isStart,
  }) {
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
                  itemExtent: 40,
                  initialDateTime: _temporaryDate,
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => _temporaryDate = newDate);
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
                      timeApply(isStart);
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

  TextField scheduleTextField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextField(
      keyboardType: TextInputType.number, //숫자키보드
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], //오직 숫자입력
      controller: controller,
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
