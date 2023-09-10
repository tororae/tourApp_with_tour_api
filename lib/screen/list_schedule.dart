///위치를 기반으로 api를 호출하여 불러온 목록을 보여주는 화면.
///

import 'package:flutter/material.dart';
import 'package:tour_with_tourapi/screen/get_location_base_info.dart';
import 'package:tour_with_tourapi/setting/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScheduleList extends StatefulWidget {
  final String apiUrl;

  const ScheduleList({super.key, required this.apiUrl});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  bool _isProgressing = false;

  ///initState는 최초 한번만 선언되서 새로고침이 안되서 우선 제외.
  ///

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   getLocationBasedData(widget.apiUrl).then(
  //     (value) {
  //       setState(
  //         () {
  //           debugPrint("${widget.apiUrl}을 통한 호출 완료!!!!!!!!!");
  //           debugPrint("${locationList[0].imageUrl}이미지 주소.");
  //         },
  //       );
  //     },
  //   );
  // }

  ///화면 나갔다왔을때 새로고침을 위한 didChangeDependencies 사용.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isProgressing = true;
    // 이전 화면에서 돌아올 때마다 데이터를 다시 불러오고 화면을 갱신합니다.
    getLocationBasedData(widget.apiUrl).then(
      (value) {
        if (mounted) {
          setState(() {
            _isProgressing = false;
            debugPrint("${widget.apiUrl}을 통한 호출 완료!!!!!!!!!");
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isProgressing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "목록을 불러오고 있어요!!",
                    style: TextStyle(
                        color: mainColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  LoadingAnimationWidget.horizontalRotatingDots(
                    color: mainColor,
                    size: 150,
                  ),
                ],
              ),
            )
          : locationList.isEmpty
              ? Center(
                  // 데이터가 없는 경우 표시할 위젯
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "해당 조건에 맞는 결과가 없습니다.",
                        style: TextStyle(color: mainColor),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              '이전 페이지로 돌아가기',
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
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Text("${locationList.length}개의 검색결과가 있습니다."),
                      const Expanded(child: TourSpotList()),
                    ],
                  ),
                ),
    );
  }
}

class TourSpotList extends StatelessWidget {
  const TourSpotList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: locationList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                    elevation: 20,
                    child: Text("${locationList[index].title}를 누르셨어요잉.."));
              },
            );
          },
          child: Card(
            elevation: 2.0, // 그림자 효과 추가 (선택 사항)
            margin: const EdgeInsets.all(8.0), // 카드 주위의 여백 (선택 사항)
            child: Padding(
              padding: const EdgeInsets.all(10.0), // 내용 주위의 여백 (선택 사항)
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationList[index].title,
                          style: const TextStyle(
                            overflow: TextOverflow.fade,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          locationList[index].address,
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: tourTypeColor(
                                  locationList[index].contentTypeId),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Text(
                            tourTypeText(locationList[index].contentTypeId),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 65,
                    width: 65,
                    child: Image.network(
                      locationList[index].imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        // 에러 처리 로직을 여기에 구현
                        return const Text('이미지 엄쪄.');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//관광타입에 맞는 텍스트 반환
String tourTypeText(contentTypeId) {
  String typeValue;
  switch (contentTypeId) {
    case '12':
      typeValue = "관광지";
      break;
    case '14':
      typeValue = "문화시설";
      break;
    case '15':
      typeValue = "축제공연행사";
      break;
    case '25':
      typeValue = "여행코스";
      break;
    case '28':
      typeValue = "레포츠";
      break;
    case '32':
      typeValue = "숙박";
      break;
    case '38':
      typeValue = "쇼핑";
      break;
    case '39':
      typeValue = "음식점";
      break;
    default:
      typeValue = "미분류";

      break;
  }
  return typeValue;
}

Color tourTypeColor(contentTypeId) {
  Color typeValue;
  switch (contentTypeId) {
    case '12':
      typeValue = const Color(0xFF0000FF);
      break;
    case '14':
      typeValue = const Color(0xFF006400);
      break;
    case '15':
      typeValue = const Color(0xFFFF1493);
      break;
    case '25':
      typeValue = const Color(0xFF800080);
      break;
    case '28':
      typeValue = const Color(0xFF8B4513);
      break;
    case '32':
      typeValue = const Color(0xFFFF8C00);
      break;
    case '38':
      typeValue = const Color(0xFF008B8B);
      break;
    case '39':
      typeValue = const Color(0xFF008080);
      break;
    default:
      typeValue = const Color(0xFF333333);

      break;
  }
  return typeValue;
}
