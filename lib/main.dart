import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_with_tourapi/screen/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:tour_with_tourapi/setting/secret.dart';

class LocationProvider with ChangeNotifier {
  String _popupLocation = "";
  String _text = "위치정보가 없습니다.";

  String get text => _text;
  String get popupLocation => _popupLocation;

  void updateText(String newText) {
    debugPrint("$newText를 받아왔습니다. $_text를 변경합니다.");
    _text = newText;
    notifyListeners();
  }

  void updatePopupText(String newText) {
    debugPrint("$newText를 받아왔습니다. $_popupLocation 변경합니다.");
    _popupLocation = newText;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
    clientId: naverMapApiKey,
    onAuthFailed: (ex) {
      debugPrint("********* 네이버맵 인증오류 : $ex *********");
    },
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: <LocalizationsDelegate<Object>>[
          // ... app-specific localization delegate(s) here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ko', ''),
          Locale('en', ''),
        ],
        home: SplashScreen(),
      ),
    );
  }
}
