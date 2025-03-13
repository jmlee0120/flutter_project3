// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
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

  // 하단 탭 항목 목록
  final List<BottomNavigationBarItem> _items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.forum),
      label: AppConstants.BOARD,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: AppConstants.MEETUP,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: AppConstants.MYPAGE,
    ),
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
        title: const Text(
          'David C.',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.green,
            fontFamily: 'Roboto',
            letterSpacing: 1.2,
          ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}