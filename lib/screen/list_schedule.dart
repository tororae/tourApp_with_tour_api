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
        setState(() {
          _isProgressing = false;
          debugPrint("${widget.apiUrl}을 통한 호출 완료!!!!!!!!!");
        });
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
              : TourSpotList(),
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
        debugPrint("$index 번째 이미지 주소 :\n${locationList[index].imageUrl} ...!!");

        return Card(
          elevation: 2.0, // 그림자 효과 추가 (선택 사항)
          margin: const EdgeInsets.all(8.0), // 카드 주위의 여백 (선택 사항)
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 내용 주위의 여백 (선택 사항)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationList[index].title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  locationList[index].address,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Image.network(
                  locationList[index].imageUrl,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    // 에러 처리 로직을 여기에 구현
                    return const Text('이미지 엄쪄.');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
