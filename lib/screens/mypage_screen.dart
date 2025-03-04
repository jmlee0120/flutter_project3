import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.MYPAGE_TITLE),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppConstants.COMING_SOON,
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '마이페이지 기능은 곧 제공될 예정입니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}