// lib/widgets/day_meetup_list.dart
// 특정 날짜의 모임 목록 위젯 구현
// 모임 목록 표시 및 빈 상태 처리


import 'package:flutter/material.dart';
import '../models/meetup.dart';
import 'meetup_card.dart';
import '../constants/app_constants.dart';

class DayMeetupList extends StatelessWidget {
  final int dayIndex;
  final List<Meetup> meetups;
  final Function(Meetup) onJoinMeetup;
  final Function(BuildContext) onCreateMeetup;
  final Function onMeetupDeleted;

  const DayMeetupList({
    Key? key,
    required this.dayIndex,
    required this.meetups,
    required this.onJoinMeetup,
    required this.onCreateMeetup,
    required this.onMeetupDeleted,
  }) : super(key: key);

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
              AppConstants.NO_MEETUPS,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(AppConstants.CREATE_MEETUP),
              onPressed: () {
                // 부모 위젯으로부터 전달받은 콜백 함수 실행
                onCreateMeetup(context);
              },
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: meetups.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[200],
        height: 1,
      ),
      itemBuilder: (context, index) {
        final meetup = meetups[index];
        return MeetupCard(
          meetup: meetup,
          onJoinMeetup: onJoinMeetup,
          meetupId: meetup.id, // 이제 이미 String 타입이므로 변환 필요 없음
          onMeetupDeleted: onMeetupDeleted,
        );
      },
    );
  }
}