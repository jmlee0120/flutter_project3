import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/meetup.dart';
import '../services/meetup_service.dart';
import '../widgets/day_meetup_list.dart';
import 'create_meetup_screen.dart';

class MeetupHomePage extends StatefulWidget {
  const MeetupHomePage({Key? key}) : super(key: key);

  @override
  State<MeetupHomePage> createState() => _MeetupHomePageState();
}

class _MeetupHomePageState extends State<MeetupHomePage> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final List<String> _days = AppConstants.DAYS;
  late List<List<Meetup>> _meetupsByDay;
  final MeetupService _meetupService = MeetupService();

  @override
  void initState() {
    super.initState();
    _meetupsByDay = _meetupService.getMeetupsByDay();
    _tabController = TabController(length: _days.length, vsync: this);

    // 오늘 요일에 맞춰 초기 탭 설정 (월요일=0, 일요일=6)
    final today = DateTime.now().weekday - 1; // 1(월)~7(일) -> 0~6
    _tabController.animateTo(today > 6 ? 6 : today);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateMeetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CreateMeetupScreen(
          initialDayIndex: _tabController.index,
          onCreateMeetup: (dayIndex, newMeetup) {
            setState(() {
              _meetupService.addMeetup(_meetupsByDay, dayIndex, newMeetup);
            });
            _tabController.animateTo(dayIndex);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.APP_TITLE),
        bottom: TabBar(
          controller: _tabController,
          tabs: _days.map((day) => Tab(text: day)).toList(),
          isScrollable: false,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicatorWeight: 3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 기능 구현 예정
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppConstants.SEARCH_NOT_READY)),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          _days.length,
              (dayIndex) => DayMeetupList(
            dayIndex: dayIndex,
            meetups: _meetupsByDay[dayIndex],
            onJoinMeetup: (meetup) {
              setState(() {
                _meetupService.joinMeetup(_meetupsByDay, dayIndex, meetup);
              });
            },
            onCreateMeetup: (context) {
              _showCreateMeetupDialog(context);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateMeetupDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: AppConstants.CREATE_MEETUP,
      ),
    );
  }
}