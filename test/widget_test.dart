import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '요일별 모임',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      home: const MeetupHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MeetupHomePage extends StatefulWidget {
  const MeetupHomePage({super.key});

  @override
  State<MeetupHomePage> createState() => _MeetupHomePageState();
}

class _MeetupHomePageState extends State<MeetupHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['월', '화', '수', '목', '금', '토', '일'];

  // 모임 데이터 모델
  final List<List<Meetup>> _meetupsByDay = List.generate(
      7,
          (dayIndex) => [
        if (dayIndex == 0) ...[
          Meetup(
            id: 1,
            title: '아침 조깅 모임',
            description: '한강에서 함께 달려요! 초보자도 환영합니다.',
            location: '잠실한강공원',
            time: '오전 7:00',
            maxParticipants: 10,
            currentParticipants: 3,
            host: '러너김',
            imageUrl: 'https://via.placeholder.com/150',
          ),
          Meetup(
            id: 2,
            title: '직장인 독서 모임',
            description: '이번 주 책: 사피엔스',
            location: '강남 카페',
            time: '오후 7:30',
            maxParticipants: 8,
            currentParticipants: 5,
            host: '책벌레',
            imageUrl: 'https://via.placeholder.com/150',
          ),
        ],
        if (dayIndex == 2) ...[
          Meetup(
            id: 3,
            title: '수요일 코딩 스터디',
            description: 'Flutter 스터디 모임입니다. 기초부터 함께해요!',
            location: '선릉역 근처 스터디카페',
            time: '오후 8:00',
            maxParticipants: 6,
            currentParticipants: 2,
            host: '개발자박',
            imageUrl: 'https://via.placeholder.com/150',
          ),
        ],
        if (dayIndex == 5) ...[
          Meetup(
            id: 4,
            title: '주말 등산 모임',
            description: '북한산 등산! 도시락 챙겨오세요~',
            location: '북한산 국립공원 입구',
            time: '오전 9:00',
            maxParticipants: 15,
            currentParticipants: 7,
            host: '산돌이',
            imageUrl: 'https://via.placeholder.com/150',
          ),
          Meetup(
            id: 5,
            title: '보드게임 번개',
            description: '다양한 보드게임을 즐겨봐요',
            location: '홍대 보드게임 카페',
            time: '오후 3:00',
            maxParticipants: 12,
            currentParticipants: 4,
            host: '게임마스터',
            imageUrl: 'https://via.placeholder.com/150',
          ),
        ],
      ]
  );

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요일별 모임'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _days.map((day) => Tab(text: '$day요일')).toList(),
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicatorWeight: 3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 기능 구현 예정
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 준비 중입니다.')),
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
                final index = _meetupsByDay[dayIndex].indexWhere((m) => m.id == meetup.id);
                if (index != -1) {
                  _meetupsByDay[dayIndex][index] = meetup.copyWith(
                    currentParticipants: meetup.currentParticipants + 1,
                  );
                }
              });
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateMeetupDialog(context);
        },
        tooltip: '새 모임 만들기',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateMeetupDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    TextEditingController maxParticipantsController = TextEditingController(text: '5');
    int selectedDayIndex = _tabController.index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 모임 만들기'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedDayIndex,
                    decoration: const InputDecoration(labelText: '요일'),
                    items: List.generate(
                      _days.length,
                          (index) => DropdownMenuItem(
                        value: index,
                        child: Text('${_days[index]}요일'),
                      ),
                    ),
                    onChanged: (value) {
                      selectedDayIndex = value!;
                    },
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: '모임 제목'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '제목을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '모임 설명'),
                    maxLines: 2,
                  ),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: '장소'),
                  ),
                  TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: '시간'),
                  ),
                  TextFormField(
                    controller: maxParticipantsController,
                    decoration: const InputDecoration(labelText: '최대 참가 인원'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    final newId = DateTime.now().millisecondsSinceEpoch;
                    final newMeetup = Meetup(
                      id: newId,
                      title: titleController.text,
                      description: descriptionController.text,
                      location: locationController.text,
                      time: timeController.text,
                      maxParticipants: int.tryParse(maxParticipantsController.text) ?? 5,
                      currentParticipants: 1, // 호스트 포함
                      host: '나',
                      imageUrl: 'https://via.placeholder.com/150',
                    );
                    _meetupsByDay[selectedDayIndex].add(newMeetup);
                  });
                  Navigator.of(context).pop();
                  _tabController.animateTo(selectedDayIndex);
                }
              },
              child: const Text('만들기'),
            ),
          ],
        );
      },
    );
  }
}

class DayMeetupList extends StatelessWidget {
  final int dayIndex;
  final List<Meetup> meetups;
  final Function(Meetup) onJoinMeetup;

  const DayMeetupList({
    super.key,
    required this.dayIndex,
    required this.meetups,
    required this.onJoinMeetup,
  });

  @override
  Widget build(BuildContext context) {
    if (meetups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '아직 모임이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('새 모임 만들기'),
              onPressed: () {
                // FAB과 동일한 기능
                final scaffoldContext = Scaffold.of(context);
                scaffoldContext.showBottomSheet(
                      (context) => Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('새 모임 만들기 기능은 준비 중입니다.'),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: meetups.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final meetup = meetups[index];
        return MeetupCard(
          meetup: meetup,
          onJoinMeetup: onJoinMeetup,
        );
      },
    );
  }
}

class MeetupCard extends StatelessWidget {
  final Meetup meetup;
  final Function(Meetup) onJoinMeetup;

  const MeetupCard({
    super.key,
    required this.meetup,
    required this.onJoinMeetup,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = meetup.currentParticipants >= meetup.maxParticipants;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모임 이미지
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.network(
                  meetup.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 179), // withOpacity(0.7)를 withValues(alpha: 179)로 수정
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${meetup.currentParticipants}/${meetup.maxParticipants}명',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 모임 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meetup.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '주최자: ${meetup.host}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      meetup.location,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      meetup.time,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  meetup.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // 참여 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: isFull
                  ? null
                  : () {
                onJoinMeetup(meetup);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${meetup.title}에 참여했습니다!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isFull ? '정원 마감' : '참여하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Meetup {
  final int id;
  final String title;
  final String description;
  final String location;
  final String time;
  final int maxParticipants;
  final int currentParticipants;
  final String host;
  final String imageUrl;

  const Meetup({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.time,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.host,
    required this.imageUrl,
  });

  Meetup copyWith({
    int? id,
    String? title,
    String? description,
    String? location,
    String? time,
    int? maxParticipants,
    int? currentParticipants,
    String? host,
    String? imageUrl,
  }) {
    return Meetup(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      time: time ?? this.time,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      host: host ?? this.host,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}