import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tour_with_tourapi/setting/secret.dart';

const apiNew = "https://api.openai.com/v1/chat/completions";

String gptSystemSetting =
    "너는 여행 가이드다. 아래 여행일정은 고객에게 제공하는 데이터다. 시간정보는 이미 제공되었으니 다시 적을 필요가 없다. 너는 추가로 제공할 여행 일정의 특징을 소개하고, 추천 팁을 알려줘라. 각 문장 사이에는 2줄의 여백을 두어서 가독성을 올려라.";

var chatbotStartValue = [
  {"role": "system", "content": gptSystemSetting},
];

//초기값 부여작업
var chatbotSetting = [chatbotStartValue.first];

//챗봇에게 질문하는 함수.
Future<String> newGenerateText(String prompt) async {
  //role system, user, assistant 존재. 각각 최초설정, 유저질문, 답변 정도
  chatbotSetting.clear();
  chatbotSetting.add(chatbotStartValue.first); //초기화 걍 여기서

  chatbotSetting.add({"role": "user", "content": prompt});
  debugPrint("-------------$chatbotSetting온전한 함수출력");

  final response = await http.post(
    Uri.parse(apiNew),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $chatGPTKey'
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": chatbotSetting,
    }),
  );

  Map<String, dynamic> newresponse =
      jsonDecode(utf8.decode(response.bodyBytes));
  debugPrint(
      "----------------------\n$newresponse \n---------------------------");
  var chatbotAnswer = newresponse['choices'][0]['message']['content'];
  //지금은 대화식으로 할 필요가 없어서 제거.
  // chatbotSetting.add({"role": "assistant", "content": chatbotAnswer});

  return chatbotAnswer;
}

//채팅 초기화
void chatReset() {
  chatbotSetting.clear();
  chatbotSetting = chatbotStartValue;

  debugPrint("$chatbotSetting가 초기화값. 음.$chatbotStartValue");
}
