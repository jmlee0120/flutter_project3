// lib/widgets/meetup_card.dart
// 모임 카드 위젯 구현
// 모임 정보 표시 및 참여 버튼 제공



import 'package:flutter/material.dart';
import '../models/meetup.dart';
import '../constants/app_constants.dart';
import '../screens/meetup_detail_screen.dart';

class MeetupCard extends StatelessWidget {
  final Meetup meetup;
  final Function(Meetup) onJoinMeetup;
  final String meetupId; // 이미 String 타입
  final Function onMeetupDeleted;

  const MeetupCard({
    Key? key,
    required this.meetup,
    required this.onJoinMeetup,
    required this.meetupId, // 이미 String으로 정의됨
    required this.onMeetupDeleted,
  }) : super(key: key);

  String _getStatusButton() {
    final isFull = meetup.currentParticipants >= meetup.maxParticipants;
    return isFull ? AppConstants.FULL : AppConstants.JOIN;
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatusButton();
    final isFull = meetup.currentParticipants >= meetup.maxParticipants;

    return InkWell(
      onTap: () {
        // 모임 상세 화면 표시
        showDialog(
          context: context,
          builder: (context) => MeetupDetailScreen(
            meetup: meetup,
            meetupId: meetupId, // meetup.id.toString() 변환 제거
            onMeetupDeleted: onMeetupDeleted,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 시간 컬럼
              SizedBox(
                width: 50,
                child: Text(
                  meetup.time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 모임 내용 컬럼
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetup.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.blue),
                        Text(
                          ' ${meetup.currentParticipants}',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 참여 버튼
              SizedBox(
                width: 60,
                child: GestureDetector(
                  onTap: isFull ? null : () {
                    onJoinMeetup(meetup);
                    // 신청 완료 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${meetup.title}${AppConstants.JOINED_MEETUP}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isFull ? Colors.grey[200] : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isFull ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}