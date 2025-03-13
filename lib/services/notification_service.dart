// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_notification.dart';
import '../models/meetup.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 알림 생성
  Future<bool> createNotification({
    required String userId, // 알림을 받을 사용자 ID
    required String title, // 알림 제목
    required String message, // 알림 내용
    required String type, // 알림 유형
    String? meetupId, // 관련 모임 ID (선택사항)
  }) async {
    try {
      final notificationData = {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'meetupId': meetupId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore.collection('notifications').add(notificationData);
      print('알림 생성 성공: $title');
      return true;
    } catch (e) {
      print('알림 생성 오류: $e');
      return false;
    }
  }

  // 모임 정원이 다 찼을 때 주최자에게 알림 보내기
  Future<bool> sendMeetupFullNotification(Meetup meetup, String hostId) async {
    try {
      return await createNotification(
        userId: hostId,
        title: '모임 정원이 다 찼습니다',
        message: '${meetup.title} 모임의 정원(${meetup.maxParticipants}명)이 모두 채워졌습니다.',
        type: 'meetup_full',
        meetupId: meetup.id,
      );
    } catch (e) {
      print('모임 정원 알림 오류: $e');
      return false;
    }
  }

  // 현재 사용자의 알림 목록 가져오기
  Stream<List<AppNotification>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      // 로그인되지 않은 경우 빈 리스트 반환
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    });
  }

  // 현재 사용자의 안 읽은 알림 수 가져오기
  Stream<int> getUnreadNotificationCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 알림 읽음 상태로 변경
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      print('알림 읽음 처리 오류: $e');
      return false;
    }
  }

  // 모든 알림 읽음 상태로 변경
  Future<bool> markAllNotificationsAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // 현재 사용자의 모든 안 읽은 알림 찾기
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // 배치 작업으로 모든 알림 업데이트
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('모든 알림 읽음 처리 오류: $e');
      return false;
    }
  }

  // 알림 삭제
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      return true;
    } catch (e) {
      print('알림 삭제 오류: $e');
      return false;
    }
  }
}