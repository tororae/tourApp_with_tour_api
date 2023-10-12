///위치를 기반으로 api를 호출하여 불러온 목록을 보여주는 화면.
///

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; //안쓸지도 모름.
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:tour_with_tourapi/screen/get_location.dart';
import 'package:tour_with_tourapi/screen/kakao_map_func.dart';
import 'package:tour_with_tourapi/screen/location_base_info.dart';
import 'package:tour_with_tourapi/setting/secret.dart';
import 'package:tour_with_tourapi/setting/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

List<dynamic> planList = []; //최종 여행정보를 담는 리스트.

//최종 여행정보를 담기 위한 모델 클래스 선언. 시작과 끝시간도 담는다.
class TourInfoData {
  final String title;
  final String address;
  final String imageUrl;
  final double dist;
  final double mapX;
  final double mapY;
  final String contentId;
  final String contentTypeId;
  final DateTime enterDate;
  final DateTime exitDate;

  TourInfoData({
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.dist,
    required this.mapX,
    required this.mapY,
    required this.contentId,
    required this.contentTypeId,
    required this.enterDate,
    required this.exitDate,
  });
}

class ScheduleList extends StatefulWidget {
  final String apiUrl;
  final DateTime startDate;
  final DateTime endDate;

  const ScheduleList(
      {super.key,
      required this.apiUrl,
      required this.startDate,
      required this.endDate});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

//지도에 그을 선을 담는 함수. 겸사겸사 경로의 중간 길이도 계산시키자.
void insertRoute() {
  tourLine.clear();
  double sumX = 0;
  double sumY = 0;
  for (var item in finalTourList) {
    tourLine.add(LatLng(item.mapY, item.mapX));
    sumX += item.mapX;
    sumY += item.mapY;
  }
  centerOfList =
      LatLng(sumY / finalTourList.length, sumX / finalTourList.length);
}

class _ScheduleListState extends State<ScheduleList> {
  bool _isProgressing = false;
  late int randomTour;

  ///화면 나갔다왔을때 새로고침을 위한 didChangeDependencies 사용.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DateTime tourSettingDate = widget.startDate;
    DateTime tourEnterDate;
    DateTime tourExitDate;

    _isProgressing = true;
    // 이전 화면에서 돌아올 때마다 데이터를 다시 불러오고 화면을 갱신합니다.
    getLocationBasedData(widget.apiUrl).then(
      (value) {
        if (mounted) {
          //화면이 없을때 setState 하면 에러남. 이를 막기 위해 mounted 되어있는지 확인하고 진행.
          bool foodEmpty = false;
          bool sleepEmpty = false;
          bool tourEmpty = false;
          if (foodList.isEmpty) {
            foodEmpty = true;
          }
          if (sleepList.isEmpty) {
            sleepEmpty = true;
          }
          if (tourList.isEmpty) {
            tourEmpty = true;
          }

          setState(
            () {
              //eated 0:식사 X 1:점심먹은상태 2:저녁먹은상태
              int eated = 0;
              String visitedContentsID = ""; //같은곳 연속방문시 체크하기 위함. 연속방문시 시간 연장.
              finalTourList.clear();

              for (int i = 0; i < 30; i++) {
                //만약 여행일정의 끝시간을 넘었다면, 끝시간으로 마지막 일정 바꾸고 종료.
                if (tourSettingDate.isAfter(widget.endDate)) {
                  debugPrint(
                      "날짜 만료됨.${widget.endDate}. ${finalTourList.length} 만들었어.");
                  final lastIndex = finalTourList.length - 1;
                  finalTourList[lastIndex] = FinalTourData(
                    title: finalTourList[lastIndex].title,
                    address: finalTourList[lastIndex].address,
                    imageUrl: finalTourList[lastIndex].imageUrl,
                    dist: finalTourList[lastIndex].dist,
                    mapX: finalTourList[lastIndex].mapX,
                    mapY: finalTourList[lastIndex].mapY,
                    contentId: finalTourList[lastIndex].contentId,
                    contentTypeId: finalTourList[lastIndex].contentTypeId,
                    enterTime: finalTourList[lastIndex].enterTime,
                    exitTime: widget.endDate,
                    itemKey: finalTourList[lastIndex].itemKey,
                  );
                  break;
                }
                //밤이 늦어 자러가는 상황
                if (tourSettingDate.hour > 21 || tourSettingDate.hour < 7) {
                  //숙소가 있어야 실행.
                  if (sleepEmpty == false) {
                    randomTour = Random().nextInt(sleepList.length);

                    //입장시간 저장 루틴
                    tourEnterDate = tourSettingDate;

                    debugPrint(
                        "${tourSettingDate.hour}시 ${tourSettingDate.minute}분. ${sleepList[randomTour].title}로 자러간다.");

                    //숙박하면 하루 지남.
                    if (tourSettingDate.hour > 21) {
                      tourSettingDate =
                          tourSettingDate.add(const Duration(days: 1));
                      tourSettingDate = DateTime(tourSettingDate.year,
                          tourSettingDate.month, tourSettingDate.day, 7, 0);
                    }
                    //그냥 늦은입실이면 11시까지 자게 두자.
                    else {
                      tourSettingDate = DateTime(
                          tourSettingDate.year,
                          tourSettingDate.month,
                          tourSettingDate.day + 1,
                          11,
                          0);
                    }
                    tourExitDate = tourSettingDate;

                    finalTourList.add(
                      FinalTourData(
                        title: sleepList[randomTour].title,
                        address: sleepList[randomTour].address,
                        imageUrl: sleepList[randomTour].imageUrl,
                        dist: sleepList[randomTour].dist,
                        mapX: sleepList[randomTour].mapX,
                        mapY: sleepList[randomTour].mapY,
                        contentId: sleepList[randomTour].contentId,
                        contentTypeId: sleepList[randomTour].contentTypeId,
                        enterTime: tourEnterDate,
                        exitTime: tourExitDate,
                        itemKey: UniqueKey(),
                      ),
                    );
                    //취침후 이동시간
                    tourSettingDate = tourSettingDate
                        .add(Duration(minutes: (Random().nextInt(5) + 1) * 10));
                    debugPrint(
                        "${tourSettingDate.hour}시 ${tourSettingDate.minute}분. ${sleepList[randomTour].title}에서 기상 완료.");
                  }
                  //숙소가 없으므로 그냥 시간 7시로 이동.
                  else {
                    debugPrint("숙소가 없어서 숙박 넘김");

                    tourSettingDate = DateTime(tourSettingDate.year,
                        tourSettingDate.month, tourSettingDate.day + 1, 7, 0);
                  }
                }

                //11시~1시 사이 점심식사
                else if (tourSettingDate.hour >= 11 &&
                    tourSettingDate.hour < 13 &&
                    eated != 1) {
                  //식당 목록이 비었으면 그냥 시간 넘겨야함.
                  if (foodEmpty == false) {
                    eated = 1;
                    randomTour = Random().nextInt(foodList.length);
                    debugPrint(
                        "${tourSettingDate.hour}시 ${tourSettingDate.minute}분. ${foodList[randomTour].title} 점심식사.");

                    //점심 한시간~
                    tourEnterDate = tourSettingDate;
                    tourSettingDate =
                        tourSettingDate.add(const Duration(hours: 1));
                    tourExitDate = tourSettingDate;

                    finalTourList.add(
                      FinalTourData(
                        title: foodList[randomTour].title,
                        address: foodList[randomTour].address,
                        imageUrl: foodList[randomTour].imageUrl,
                        dist: foodList[randomTour].dist,
                        mapX: foodList[randomTour].mapX,
                        mapY: foodList[randomTour].mapY,
                        contentId: foodList[randomTour].contentId,
                        contentTypeId: foodList[randomTour].contentTypeId,
                        enterTime: tourEnterDate,
                        exitTime: tourExitDate,
                        itemKey: UniqueKey(),
                      ),
                    );
                    //식사후 이동시간
                    tourSettingDate = tourSettingDate
                        .add(Duration(minutes: (Random().nextInt(5) + 1) * 10));
                  } else {
                    debugPrint("음식이 없어서 저녁 넘김");

                    tourSettingDate = DateTime(tourSettingDate.year,
                        tourSettingDate.month, tourSettingDate.day, 13, 0);
                    eated = 1;
                  }
                }

                //18시~19시 사이 저녁식사
                else if (tourSettingDate.hour >= 18 &&
                    tourSettingDate.hour <= 19 &&
                    eated != 2) {
                  if (foodEmpty == false) {
                    eated = 2;
                    randomTour = Random().nextInt(foodList.length);
                    debugPrint(
                        "${tourSettingDate.hour}시 ${tourSettingDate.minute}분. ${foodList[randomTour].title} 저녁식사.");

                    //저녁 한시간~
                    tourEnterDate = tourSettingDate;
                    tourSettingDate =
                        tourSettingDate.add(const Duration(hours: 1));
                    tourExitDate = tourSettingDate;

                    finalTourList.add(
                      FinalTourData(
                        title: foodList[randomTour].title,
                        address: foodList[randomTour].address,
                        imageUrl: foodList[randomTour].imageUrl,
                        dist: foodList[randomTour].dist,
                        mapX: foodList[randomTour].mapX,
                        mapY: foodList[randomTour].mapY,
                        contentId: foodList[randomTour].contentId,
                        contentTypeId: foodList[randomTour].contentTypeId,
                        enterTime: tourEnterDate,
                        exitTime: tourExitDate,
                        itemKey: UniqueKey(),
                      ),
                    );

                    //식사후 이동시간
                    tourSettingDate = tourSettingDate
                        .add(Duration(minutes: (Random().nextInt(5) + 1) * 10));
                  } else {
                    debugPrint("음식이 없어서 저녁 넘김");
                    eated = 2;
                    tourSettingDate = DateTime(tourSettingDate.year,
                        tourSettingDate.month, tourSettingDate.day, 29, 0);
                  }
                } else {
                  if (tourEmpty == false) {
                    randomTour = Random().nextInt(tourList.length);

                    debugPrint(
                        "${tourSettingDate.hour}시. ${tourList[randomTour].title}로 관광간다.");

                    debugPrint(
                        "${tourSettingDate.hour}시 ${tourSettingDate.minute}분. 관광 끝.. ");

                    tourEnterDate = tourSettingDate;
                    tourSettingDate = tourSettingDate
                        .add(Duration(hours: Random().nextInt(2) + 1));
                    tourExitDate = tourSettingDate;
                    if (tourList[randomTour].contentId == visitedContentsID) {
                      debugPrint("드가다 죽어여.");
                      final int lastIndex = finalTourList.length - 1;
                      finalTourList[lastIndex] = FinalTourData(
                        title: finalTourList[lastIndex].title,
                        address: finalTourList[lastIndex].address,
                        imageUrl: finalTourList[lastIndex].imageUrl,
                        dist: finalTourList[lastIndex].dist,
                        mapX: finalTourList[lastIndex].mapX,
                        mapY: finalTourList[lastIndex].mapY,
                        contentId: finalTourList[lastIndex].contentId,
                        contentTypeId: finalTourList[lastIndex].contentTypeId,
                        enterTime: finalTourList[lastIndex].enterTime,
                        exitTime: tourExitDate,
                        itemKey: finalTourList[lastIndex].itemKey,
                      );
                    } else {
                      visitedContentsID = tourList[randomTour].contentId;

                      finalTourList.add(
                        FinalTourData(
                          title: tourList[randomTour].title,
                          address: tourList[randomTour].address,
                          imageUrl: tourList[randomTour].imageUrl,
                          dist: tourList[randomTour].dist,
                          mapX: tourList[randomTour].mapX,
                          mapY: tourList[randomTour].mapY,
                          contentId: tourList[randomTour].contentId,
                          contentTypeId: tourList[randomTour].contentTypeId,
                          enterTime: tourEnterDate,
                          exitTime: tourExitDate,
                          itemKey: UniqueKey(),
                        ),
                      );
                    }

                    //관광이후 이동시간
                    tourSettingDate = tourSettingDate
                        .add(Duration(minutes: (Random().nextInt(5) + 1) * 10));
                  }
                  //관광지 없으면 밥이나 먹게 무한 이동.
                  else {
                    debugPrint("관광지 없어서 여행 넘김");

                    if (eated == 1) {
                      eated = 2;
                      tourSettingDate = DateTime(tourSettingDate.year,
                          tourSettingDate.month, tourSettingDate.day, 16, 0);
                    } else {
                      eated = 1;
                      tourSettingDate = DateTime(tourSettingDate.year,
                          tourSettingDate.month, tourSettingDate.day, 22, 0);
                    }
                  }
                }

                /////
              }
              _isProgressing = false;
              debugPrint("${widget.apiUrl}을 통한 호출 완료!!!!!!!!!");
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isProgressing //api 호출값 로딩 완료후 화면 호출
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
          : finalTourList.isEmpty
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
                      const SizedBox(height: 10),
                      // Text("AI 검색 결과\n${finalTourList.length} 방문을 추천합니다."),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              insertRoute();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const KakaoMapTourList();
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: mainColor, width: 2),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("여행경로 보기"),
                                  Icon(Icons.route, color: mainColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      const Expanded(child: TourSpotList()),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            ///챗 지피티 호출 기능 구현예정

                            debugPrint(
                                "시작일시 - ${DateFormat('yyyy.MM.dd. HH:mm').format(widget.startDate)}");
                            debugPrint(
                                "종료일시 - ${DateFormat('yyyy.MM.dd. HH:mm').format(widget.endDate)}");
                            int listNum = 0;
                            String dataForSendGPT = tourSetting;
                            for (var element in finalTourList) {
                              listNum++;
                              dataForSendGPT =
                                  "$dataForSendGPT i:$listNum name:${element.title}, code:${element.contentTypeId}, location:${element.mapX},${element.mapY}.\n";
                              if (listNum > 100) {
                                debugPrint(dataForSendGPT);
                                Clipboard.setData(
                                  ClipboardData(text: dataForSendGPT),
                                );
                                break;
                              }
                            }
                            // debugPrint(
                            // "${locationList[0].title}, ${locationList[0].contentTypeId}, ${locationList[0].mapX},${locationList[0].mapY},");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              '여행일정 요청',
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
    );
  }
}

//API 호출을 위한 ID들 변수할당
String contentIdValue = "";
String contentTypeIdValue = "";

//리스트 내 들어가는 관광지들 목록
class TourSpotList extends StatefulWidget {
  const TourSpotList({
    super.key,
  });

  @override
  State<TourSpotList> createState() => _TourSpotListState();
}

class _TourSpotListState extends State<TourSpotList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        setState(
          () {
            if (oldIndex < newIndex) {
              newIndex--;
            }
            final oldEnterTime = finalTourList[oldIndex].enterTime;
            final oldExitTime = finalTourList[oldIndex].exitTime;

            debugPrint(
                "${finalTourList[oldIndex].title}, ${finalTourList[newIndex].title}을 바꾼다.");

            //교체시 시간 서로 바꾸게
            finalTourList[oldIndex] = FinalTourData(
                title: finalTourList[oldIndex].title,
                address: finalTourList[oldIndex].address,
                imageUrl: finalTourList[oldIndex].imageUrl,
                dist: finalTourList[oldIndex].dist,
                mapX: finalTourList[oldIndex].mapX,
                mapY: finalTourList[oldIndex].mapY,
                contentId: finalTourList[oldIndex].contentId,
                contentTypeId: finalTourList[oldIndex].contentTypeId,
                enterTime: finalTourList[newIndex].enterTime,
                exitTime: finalTourList[newIndex].enterTime,
                itemKey: finalTourList[oldIndex].itemKey);

            finalTourList[newIndex] = FinalTourData(
                title: finalTourList[newIndex].title,
                address: finalTourList[newIndex].address,
                imageUrl: finalTourList[newIndex].imageUrl,
                dist: finalTourList[newIndex].dist,
                mapX: finalTourList[newIndex].mapX,
                mapY: finalTourList[newIndex].mapY,
                contentId: finalTourList[newIndex].contentId,
                contentTypeId: finalTourList[newIndex].contentTypeId,
                enterTime: oldEnterTime,
                exitTime: oldExitTime,
                itemKey: finalTourList[newIndex].itemKey);

            debugPrint("변경전 $oldIndex와 $newIndex");

            final item = finalTourList.removeAt(oldIndex);
            finalTourList.insert(newIndex, item);
            debugPrint(
                "변경후 $oldIndex와 $newIndex. ${finalTourList[oldIndex].title}");
          },
        );
      },
      itemCount: finalTourList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          key: finalTourList[index].itemKey,

          //클릭시 상세정보 보여주는 부분
          onTap: () {
            contentIdValue = finalTourList[index].contentId;
            contentTypeIdValue = finalTourList[index].contentTypeId;
            showDialog(
              context: context,
              builder: (context) {
                return DetailInfoDialog(
                  address: finalTourList[index].address,
                  mapX: finalTourList[index].mapX,
                  mapY: finalTourList[index].mapY,
                  enterTime: finalTourList[index].enterTime,
                  exitTime: finalTourList[index].exitTime,
                  title: finalTourList[index].title,
                  imageUrl: finalTourList[index].imageUrl,
                  // key: key,
                );
              },
            );
          },
          child: Column(
            children: [
              if (index != 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      spotDurationCalc(index),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: mainColor, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          // finalTourList.insert(
                          //   index,
                          //   FinalTourData(
                          //     title: foodList[0].title,
                          //     address: foodList[0].address,
                          //     imageUrl: foodList[0].imageUrl,
                          //     dist: foodList[0].dist,
                          //     mapX: foodList[0].mapX,
                          //     mapY: foodList[0].mapY,
                          //     contentId: foodList[0].contentId,
                          //     contentTypeId: foodList[0].contentTypeId,
                          //     enterTime: DateTime.now(),
                          //     exitTime: DateTime.now(),
                          //     itemKey: UniqueKey(),
                          //   ),
                          // );
                        });
                        showDialog(
                          context: context,
                          builder: (context) {
                            int category = 0;
                            int categoryLength = locationList.length;
                            var target = locationList;
                            return StatefulBuilder(
                              builder: (context, setState) => Dialog(
                                elevation: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  debugPrint("$index를 누름.");
                                                  if (category != 0) {
                                                    setState(() {
                                                      category = 0;
                                                      categoryLength =
                                                          locationList.length;
                                                      target = locationList;
                                                    });
                                                  }
                                                  debugPrint("$category 누름.");
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: category == 0
                                                        ? mainColor
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: mainColor),
                                                  ),
                                                  child: Text(
                                                    "전체",
                                                    style: TextStyle(
                                                      color: category == 0
                                                          ? Colors.white
                                                          : mainColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  debugPrint("$index를 누름.");
                                                  if (category != 1) {
                                                    setState(() {
                                                      category = 1;
                                                      categoryLength =
                                                          tourList.length;
                                                      target = tourList;
                                                    });
                                                  }
                                                  debugPrint("$category 누름.");
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: category == 1
                                                        ? mainColor
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: mainColor),
                                                  ),
                                                  child: Text(
                                                    "관광",
                                                    style: TextStyle(
                                                      color: category == 1
                                                          ? Colors.white
                                                          : mainColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  debugPrint("$index를 누름.");
                                                  if (category != 2) {
                                                    setState(() {
                                                      category = 2;
                                                      categoryLength =
                                                          foodList.length;
                                                      target = foodList;
                                                    });
                                                  }
                                                  debugPrint("$category 누름.");
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: category == 2
                                                        ? mainColor
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: mainColor),
                                                  ),
                                                  child: Text(
                                                    "식사",
                                                    style: TextStyle(
                                                      color: category == 2
                                                          ? Colors.white
                                                          : mainColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (category != 3) {
                                                    setState(() {
                                                      category = 3;
                                                      categoryLength =
                                                          sleepList.length;
                                                      target = sleepList;
                                                    });
                                                  }
                                                  debugPrint("$category 누름.");
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: category == 3
                                                        ? mainColor
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: mainColor),
                                                  ),
                                                  child: Text(
                                                    "숙박",
                                                    style: TextStyle(
                                                      color: category == 3
                                                          ? Colors.white
                                                          : mainColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: categoryLength,
                                          itemBuilder: (context, index) {
                                            return Text(target[index].title);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: mainColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            "취소",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Card(
                        elevation: 5,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                          child: Icon(
                            Icons.add_location_alt_outlined,
                            color: mainColor,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "목적지 거리\n${calculateDistance(latStart: finalTourList[index - 1].mapY, lngStart: finalTourList[index - 1].mapX, latEnd: finalTourList[index].mapY, lngEnd: finalTourList[index].mapX)}",
                      style: const TextStyle(
                          color: mainColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              Card(
                elevation: 10, // 그림자 효과 추가 (선택 사항)
                margin: const EdgeInsets.all(8.0), // 카드 주위의 여백 (선택 사항)
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // 내용 주위의 여백 (선택 사항)
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        flex: 6,
                        fit: FlexFit.tight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${index + 1}. ${finalTourList[index].title}",
                              style: const TextStyle(
                                overflow: TextOverflow.fade,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              finalTourList[index].address,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(height: 5),

                            //입장시간
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: mainColor),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "IN",
                                            style: TextStyle(
                                              color: mainColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            DateFormat("MM월 dd일\nHH:mm").format(
                                                finalTourList[index].enterTime),
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: mainColor),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "OUT",
                                            style: TextStyle(
                                              color: mainColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            DateFormat("MM월 dd일\nHH:mm").format(
                                                finalTourList[index].exitTime),
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Flexible(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: tourTypeColor(
                                      finalTourList[index].contentTypeId),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5))),
                              child: Text(
                                tourTypeText(
                                    finalTourList[index].contentTypeId),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 100,
                              height: 60,
                              child: Image.network(
                                finalTourList[index].imageUrl,
                                fit: BoxFit.fill,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  // 에러 처리 로직을 여기에 구현
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        color: mainColor,
                                      ),
                                      Text(
                                        'No Image',
                                        style: TextStyle(color: mainColor),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                debugPrint("$index 번째를 눌렀다.");
                                setState(() {
                                  finalTourList.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: mainColor,
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    Text(
                                      "삭제하기",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
  final DateTime enterTime;
  final DateTime exitTime;

  final String imageUrl;
  const DetailInfoDialog({
    required this.title,
    super.key,
    required this.address,
    required this.mapX,
    required this.mapY,
    required this.enterTime,
    required this.exitTime,
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
              Image.network(
                widget.imageUrl,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  // 에러 처리 로직을 여기에 구현
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        color: mainColor,
                      ),
                      Text(
                        'No Image',
                        style: TextStyle(color: mainColor),
                      ),
                    ],
                  );
                },
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
                      child: KakaoMap(
                        onMapCreated: ((controller) async {
                          markers.clear();
                          markers.add(Marker(
                            markerId: UniqueKey().toString(),
                            latLng: LatLng(widget.mapY, widget.mapX),
                          ));
                          setState(() {});
                        }),
                        markers: markers.toList(),
                        center: LatLng(widget.mapY, widget.mapX),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
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

String spotDurationCalc(int index) {
  String returnDuration = "시간 간격\n";
  if (finalTourList[index]
          .enterTime
          .difference(finalTourList[index - 1].exitTime)
          .inHours >
      0) {
    returnDuration +=
        "${finalTourList[index].enterTime.difference(finalTourList[index - 1].exitTime).inHours}시간 ";
  }
  if (finalTourList[index]
              .enterTime
              .difference(finalTourList[index - 1].exitTime)
              .inMinutes %
          60 >
      0) {
    returnDuration +=
        "${finalTourList[index].enterTime.difference(finalTourList[index - 1].exitTime).inMinutes % 60}분";
  }
  return returnDuration;
}

//관광타입에 맞는 컬러 반환
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
