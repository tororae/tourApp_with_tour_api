///위치를 기반으로 api를 호출하여 불러온 목록을 보여주는 화면.
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tour_with_tourapi/screen/get_location_base_info.dart';
import 'package:tour_with_tourapi/screen/naver_map_func.dart';
import 'package:tour_with_tourapi/setting/secret.dart';
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

//API 호출을 위한 ID들 변수할당
String contentIdValue = "";
String contentTypeIdValue = "";

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
            contentIdValue = locationList[index].contentId;
            contentTypeIdValue = locationList[index].contentTypeId;

            showDialog(
              context: context,
              builder: (context) {
                return DetailInfoDialog(
                  address: locationList[index].address,
                  mapX: locationList[index].mapX,
                  mapY: locationList[index].mapY,
                  title: locationList[index].title,
                  imageUrl: locationList[index].imageUrl,
                  key: key,
                );
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

//상세정보 반환
class DetailInfoDialog extends StatefulWidget {
  final String title;
  final String address;
  final double mapX;
  final double mapY;
  final String imageUrl;
  const DetailInfoDialog({
    required this.title,
    super.key,
    required this.address,
    required this.mapX,
    required this.mapY,
    required this.imageUrl,
  });

  @override
  State<DetailInfoDialog> createState() => _DetailInfoDialogState();
}

class _DetailInfoDialogState extends State<DetailInfoDialog> {
  String detailInfoText = "";
  final String infoURL =
      "$tourApiMainUrl$detailInfoBeforeKey$tourApiKey$detailInfoAfterKey$contentId$contentIdValue$contentTypeId$contentTypeIdValue$detailInfoLast";
  @override
  void initState() {
    debugPrint(infoURL);
    isInfoLoading = true;

    setState(() {});
    getDetailInfo(infoURL).then(
      (value) {
        if (mounted) {
          setState(() {
            detailInfoText = value;
          });
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isExit = false;
    return Dialog(
      elevation: 20,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 25,
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border.all(color: mainColor, width: 1.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Image.network(
                  widget.imageUrl,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    // 에러 처리 로직을 여기에 구현
                    return const Text('이미지 엄쪄.');
                  },
                ),
              ),
              const SizedBox(height: 15),
              const SizedBox(
                width: double.infinity,
                child: Text(
                  "상세설명",
                  style: TextStyle(
                    fontSize: 18,
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              isInfoLoading == true
                  ? LoadingAnimationWidget.fourRotatingDots(
                      color: mainColor, size: 50)
                  : Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(color: mainColor, width: 1.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 100,
                      child: SingleChildScrollView(
                        child: HtmlWidget(
                          detailInfoText,
                        ),
                      ),
                    ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    "주소",
                    style: TextStyle(
                      fontSize: 18,
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      size: 25,
                      Icons.content_copy_rounded,
                      color: mainColor,
                    ),
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: "주소를 복사하였습니다.",
                      );
                      Clipboard.setData(
                        ClipboardData(text: widget.address),
                      );
                    },
                  )
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: mainColor, width: 1.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      widget.address,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: isExit == false
                          ? naverMapCallJustSee(
                              mapX: widget.mapX, mapY: widget.mapY)
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  isExit = true;
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    '닫기',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
