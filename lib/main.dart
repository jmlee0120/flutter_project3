import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MeetupApp());
}

class MeetupApp extends StatelessWidget {
  const MeetupApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '요일별 모임',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}