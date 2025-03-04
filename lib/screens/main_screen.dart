import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'board_screen.dart';
import 'home_screen.dart';
import 'mypage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // 기본값으로 모임 탭 선택

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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}