// ignore: file_names
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: const Scaffold(
        body: Center(
          child: Text("글자다 으왕"),
        ),
      ),
    );
  }
}
