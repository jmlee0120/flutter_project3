// lib/screens/meetup_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meetup.dart';
import '../services/meetup_service.dart';
import '../providers/auth_provider.dart';

class MeetupDetailScreen extends StatefulWidget {
  final Meetup meetup;
  final String meetupId;
  final Function onMeetupDeleted;

  const MeetupDetailScreen({
    Key? key,
    required this.meetup,
    required this.meetupId,
    required this.onMeetupDeleted,
  }) : super(key: key);

  @override
  State<MeetupDetailScreen> createState() => _MeetupDetailScreenState();
}

class _MeetupDetailScreenState extends State<MeetupDetailScreen> {
  final MeetupService _meetupService = MeetupService();
  bool _isLoading = false;
  bool _isHost = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsHost();
  }

  Future<void> _checkIfUserIsHost() async {
    final isHost = await _meetupService.isUserHostOfMeetup(widget.meetupId);
    if (mounted) {
      setState(() {
        _isHost = isHost;
      });
    }
  }

  Future<void> _deleteMeetup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _meetupService.deleteMeetup(widget.meetupId);

      if (success) {
        if (mounted) {
          // 콜백 호출하여 부모 화면 업데이트
          widget.onMeetupDeleted();

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('모임이 취소되었습니다.')),
          );
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임 취소에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // currentUserNickname 변수 제거 (사용되지 않음)

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 모임 제목
            Text(
              widget.meetup.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 모임 날짜 및 시간
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${widget.meetup.date.month}월 ${widget.meetup.date.day}일',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  widget.meetup.time,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 모임 장소
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.meetup.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 주최자 정보
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '주최자: ${widget.meetup.host}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 참가자 정보
            Row(
              children: [
                const Icon(Icons.groups, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '참가자: ${widget.meetup.currentParticipants}/${widget.meetup.maxParticipants}명',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 모임 설명
            const Text(
              '모임 설명',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.meetup.description),
            const SizedBox(height: 24),

            // 주최자인 경우 취소 버튼을 보여주는 박스
            if (_isHost)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 26), // withOpacity(0.1)를 withValues(alpha: 26)으로 변경
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 77)), // withOpacity(0.3)를 withValues(alpha: 77)으로 변경
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '주최자 관리',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이 모임을 취소하시면 모임 목록에서 삭제됩니다.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _deleteMeetup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('모임 취소'),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 버튼 영역
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}