// lib/models/app_notification.dart
// 앱 내 알림 데이터 모델 정의
// 알림 유형, 내용, 읽음상태 등의 속성 포함
// Firestore 데이터 변환 및 관리 메서드 제공

import 'package:cloud_firestore/cloud_firestore.dart';

// 일반 Notification 클래스와 이름 충돌을 방지하기 위해 AppNotification으로 명명
class AppNotification {
  final String id;
  final String userId; // 알림을 받을 사용자 ID
  final String title; // 알림 제목
  final String message; // 알림 내용
  final String type; // 알림 유형 (예: 'meetup_full', 'new_comment' 등)
  final String? meetupId; // 관련 모임 ID (모임 관련 알림인 경우)
  final DateTime createdAt; // 알림 생성 시간
  final bool isRead; // 읽음 여부

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.meetupId,
    required this.createdAt,
    this.isRead = false,
  });

  // Firestore 문서에서 AppNotification 객체 생성
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      meetupId: data['meetupId'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  // Firestore에 저장할 맵 생성
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'meetupId': meetupId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  // 읽음 상태를 변경한 새 객체 반환
  AppNotification copyWithRead(bool read) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      meetupId: meetupId,
      createdAt: createdAt,
      isRead: read,
    );
  }
}