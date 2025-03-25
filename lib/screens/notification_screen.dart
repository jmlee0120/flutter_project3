// lib/screens/notification_screen.dart
// 알림 목록 화면
// 알림 표시 및 읽음 처리



import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import 'meetup_detail_screen.dart';
import '../services/meetup_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 화면을 열 때 모든 알림 읽음 처리
    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.markAllNotificationsAsRead();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 알림 항목 위젯 생성
  Widget _buildNotificationItem(AppNotification notification) {
    // 알림 유형에 따른 아이콘 및 색상 설정
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'meetup_full':
        iconData = Icons.group;
        iconColor = Colors.green;
        break;
      case 'new_comment':
        iconData = Icons.chat_bubble_outline;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Dismissible(
        key: Key(notification.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _notificationService.deleteNotification(notification.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('알림이 삭제되었습니다')),
          );
        },

    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // 아직 읽지 않은 알림인 경우 읽음 처리
          if (!notification.isRead) {
            _notificationService.markNotificationAsRead(notification.id);
          }

          // 모임 관련 알림인 경우 관련 화면으로 이동
          if (notification.type == 'meetup_full' && notification.meetupId != null) {
            // 이제 알림이 클릭되었다는 메시지만 표시하는 대신 모임 상세 페이지로 이동합니다
            try {
              // 로딩 표시
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              // MeetupService 직접 생성하여 사용
              final meetupService = MeetupService();

              // 알림에 해당하는 모임 정보 가져오기
              meetupService.getMeetupById(notification.meetupId!).then((meetup) {
                // 로딩 다이얼로그 닫기
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                if (meetup != null && context.mounted) {
                  // 모임 상세 화면 열기
                  showDialog(
                    context: context,
                    builder: (context) => MeetupDetailScreen(
                      meetup: meetup,
                      meetupId: notification.meetupId!,
                      onMeetupDeleted: () {
                        // 모임 삭제 후 처리
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('모임이 취소되었습니다')),
                        );
                      },
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('해당 모임을 찾을 수 없습니다')),
                  );
                }
              }).catchError((e) {
                // 로딩 다이얼로그가 열려있다면 닫기
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('모임 정보를 불러오는 중 오류가 발생했습니다: $e')),
                  );
                }
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('오류가 발생했습니다: $e')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 알림 아이콘
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // 알림 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatNotificationTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // 읽지 않은 알림 표시
              if (!notification.isRead)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  // 알림 시간 포맷팅
  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          // 모든 알림 읽음 버튼
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _isLoading ? null : _markAllAsRead,
            tooltip: '모든 알림 읽음',
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationService.getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('알림을 불러오는 중 오류가 발생했습니다: ${snapshot.error}'),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '알림이 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // 당겨서 새로고침 시 상태 업데이트
              setState(() {});
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(notifications[index]);
              },
            ),
          );
        },
      ),
    );
  }
}