import 'package:flutter/material.dart';
import 'package:tour_with_tourapi/screen/get_location_base_info.dart';

class ScheduleList extends StatefulWidget {
  final String apiUrl;

  const ScheduleList({super.key, required this.apiUrl});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
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
    // 이전 화면에서 돌아올 때마다 데이터를 다시 불러오고 화면을 갱신합니다.
    getLocationBasedData(widget.apiUrl).then(
      (value) {
        setState(() {
          debugPrint("${widget.apiUrl}을 통한 호출 완료!!!!!!!!!");
          debugPrint("${locationList[0].imageUrl}이미지 주소.");
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: locationList.length,
        itemBuilder: (BuildContext context, int index) {
          debugPrint(
              "$index 번째 이미지 주소 :\n${locationList[index].imageUrl} ...!!");

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
      ),
    );
  }
}
