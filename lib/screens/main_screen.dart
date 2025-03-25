// lib/screens/main_screen.dart
// 앱의 메인화면 구현
// 하단 탭 네비게이션 제공
// 게시판, 모임, 마이페이지 화면 통합



import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart'; // 이 패키지 추가 필요
import '../constants/app_constants.dart';
import '../services/notification_service.dart';
import '../widgets/notification_badge.dart';
import 'board_screen.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';
import 'notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // 기본값으로 모임 탭 선택
  final NotificationService _notificationService = NotificationService();

  // 화면 목록
  final List<Widget> _screens = [
    const BoardScreen(),
    const MeetupHomePage(),
    const MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 모든 화면에서 공통으로 사용할 AppBar
      appBar: AppBar(
        title: Image.asset(
          'assets/icons/macaron_appbarlogo.png',
          height: 25,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // 알림 버튼
          StreamBuilder<int>(
            stream: _notificationService.getUnreadNotificationCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return NotificationBadge(
                count: unreadCount,
                child: IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // 알림 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                  tooltip: '알림',
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],

      // 수정된 하단바: 라운딩 효과 유지하면서 선택된 아이템은 아이콘과 텍스트 색상만 변경
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react, // 라운딩 효과를 위해 react 스타일 사용
        backgroundColor: Colors.white,
        color: Colors.grey, // 선택되지 않은 아이템 색상
        activeColor: Colors.blue, // 선택된 아이템 색상
        elevation: 4, // 그림자 효과
        items: [
          TabItem(icon: Icons.forum, title: AppConstants.BOARD),
          TabItem(icon: Icons.people, title: AppConstants.MEETUP),
          TabItem(icon: Icons.person, title: AppConstants.MYPAGE),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
        height: 60, // 하단바 높이 조정
        top: -3, // 얼마나 위로 튀어나오게 할지 (음수 값)
        curveSize: 90, // 곡률 크기
        curve: Curves.easeInOut, // 부드러운 곡선 효과 추가
      ),
    );
  }
}