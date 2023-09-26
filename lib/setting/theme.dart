import 'package:flutter/material.dart';

const Color mainColor = Color(0xff693FDD);
const Color subColor = Color(0xff523EBF);
const Color backColor = Color(0xffF6F8FA);

double currentLongitude = 126.734086;
double currentLatitude = 37.715133;

String tourSetting = '''너는 여행일정을 짜는 api다.
API 활용을 위해 오직 JSON 만 반환해야 한다.
나는 소스를 원하는게 아니고 아래 정보를 활용한 json 반환값을 원한다.
반환형식은 아래와 같다.
반환형식 외의 글은 절대 금지한다.
{
  "schedule": [
    {
      "name":"김밥천국",
      "i":"5",
      "start_time": "202309140700",
      "end_time": "202309140800",
      "purpose": "관광"
    },
    {
      "name":"아쿠아리움",
      "i":"8",
      "start_time": "202309140800",
      "end_time": "202309141200",
      "purpose": "숙박"
    },
    ...
  ],
  "opinion":"여행에 대한 의견"
}

여행정보
시작일시 - 2023.09.14. 21:57, 종료일시 - 2023.09.16. 07:00

i - 여행지 목록에서 선정한 아이템의 인덱스를 기입한다.
name - 여행지 목록에서 선정한 아이템의 이름을 기입한다.
start_time - 해당 일정의 시작 시간을 적는다.
end_time - 해당 일정의 종료 시간을 적는다.
purpose - 해당 일정의 이유를 적는다. (숙박, 여행, 아침, 점심, 저녁, 휴식 등)
opinion - 해당 여행코스를 제안한 이유를 적는다.


코드의 의미-
12:관광지14:문화시설15:축제공연행사25:여행코스28:레포츠32:숙박38:쇼핑39:음식점';
''';
