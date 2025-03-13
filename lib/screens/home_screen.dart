import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/meetup.dart';
import '../services/meetup_service.dart';
import '../widgets/day_meetup_list.dart';
import 'create_meetup_screen.dart';

class MeetupHomePage extends StatefulWidget {
  const MeetupHomePage({super.key});

  @override
  State<MeetupHomePage> createState() => _MeetupHomePageState();
}

class _MeetupHomePageState extends State<MeetupHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
  // 기존 메모리 기반 데이터 - 필요시 폴백으로 사용
  late List<List<Meetup>> _localMeetupsByDay;
  final MeetupService _meetupService = MeetupService();

  @override
  void initState() {
    super.initState();
    // 메모리 기반 데이터 로드 (폴백용)
    _localMeetupsByDay = _meetupService.getMeetupsByDayFromMemory();
    _tabController = TabController(length: 7, vsync: this);

    // 초기 탭은 항상 첫 번째 탭 (오늘)
    _tabController.animateTo(0);
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
          onCreateMeetup: (dayIndex, newMeetup) async {
            // CreateMeetupScreen에서 이미 Firebase에 저장됨
            // 해당 요일 탭으로 이동
            _tabController.animateTo(dayIndex);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 날짜 기준 일주일 날짜 계산 (오늘부터 6일 후까지)
    final List<DateTime> weekDates = _meetupService.getWeekDates();

    return Scaffold(
      body: Column(
        children: [
          // 상단 헤더 - "Make your gathering!" 텍스트
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: const Text(
              "Make your gathering!",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // 탭바
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: List.generate(
                weekDates.length,
                    (index) => Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 요일 (월, 화, 수, ...)
                      Text(_weekdayNames[weekDates[index].weekday - 1]),
                      // 날짜 (1, 2, 3, ...)
                      Text(
                        '${weekDates[index].day}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isScrollable: false,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              labelColor: Colors.blue[600],
              unselectedLabelColor: Colors.grey[800],
              indicatorColor: Colors.blue[600],
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),

          // 위치 및 현재 선택된 날짜 표시
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[600], size: 20.0),
                const SizedBox(width: 8.0),
                const Text(
                  '안산',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                // 현재 선택된 탭의 날짜 표시
                Text(
                  '${weekDates[_tabController.index].month}월 ${weekDates[_tabController.index].day}일',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 모임 목록
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                7,
                    (dayIndex) => StreamBuilder<List<Meetup>>(
                  stream: _meetupService.getMeetupsByDay(dayIndex),
                  builder: (context, snapshot) {
                    // 로딩 중 또는 에러 시 로컬 데이터 표시
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.hasError || !snapshot.hasData) {
                      return DayMeetupList(
                        dayIndex: dayIndex,
                        meetups: _localMeetupsByDay[dayIndex],

                        onJoinMeetup: (meetup) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('오프라인 모드에서는 참여할 수 없습니다.')),
                          );
                        },
                        onCreateMeetup: (context) {
                          _showCreateMeetupDialog(context);
                        },
                        onMeetupDeleted: () {
                          // 리스트 갱신 (Stream이므로 자동으로 갱신됨)
                          setState(() {});
                        },
                      );
                    }

                    // 데이터가 있으면 표시
                    final meetups = snapshot.data ?? [];
                    return DayMeetupList(
                      dayIndex: dayIndex,
                      meetups: meetups,

                        onJoinMeetup: (meetup) async {
                          try {
                            // 이제 meetup.id는 이미 String이므로 변환 불필요
                            final success = await _meetupService.joinMeetup(meetup.id);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${meetup.title}${AppConstants.JOINED_MEETUP}')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('모임 참여에 실패했습니다. 다시 시도해주세요.')),
                              );
                            }
                          } catch (e) {
                            print('모임 참여 중 오류 발생: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('오류가 발생했습니다: $e')),
                            );
                          }
                        },
                      onCreateMeetup: (context) {
                        _showCreateMeetupDialog(context);
                      },
                      onMeetupDeleted: () {
                        // 리스트 갱신 (Stream이므로 자동으로 갱신됨)
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateMeetupDialog(context);
        },
        tooltip: AppConstants.CREATE_MEETUP,
        child: const Icon(Icons.add),
      ),
    );
  }
}