// lib/models/meetup.dart
// 모임 데이터 모델 정의
// 모임 관련 속성 포함(제목,설명,작성자,작성일,좋아요 수 등)
// 모임 정보 포맷팅을 위한 유틸리티 메서드 제공


import 'package:intl/intl.dart';

class Meetup {
  final String id;
  final String title;
  final String description;
  final String location;
  final String time;
  final int maxParticipants;
  final int currentParticipants;
  final String host;
  final String imageUrl;
  final DateTime date;

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
    required this.date,
  });

  Meetup copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? time,
    int? maxParticipants,
    int? currentParticipants,
    String? host,
    String? imageUrl,
    DateTime? date,
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
      date: date ?? this.date,
    );
  }

  // 날짜 포맷 문자열 반환 함수
  String getFormattedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meetupDate = DateTime(date.year, date.month, date.day);

    final difference = meetupDate.difference(today).inDays;

    if (difference == 0) {
      return '오늘 예정';
    } else if (difference == 1) {
      return '내일 예정';
    } else if (difference > 1 && difference < 7) {
      return '$difference일 후 예정';
    } else {
      return '${date.month}월 ${date.day}일 예정';
    }
  }

  // 포맷된 요일 문자열 반환
  String getFormattedDayOfWeek() {
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
    // DateTime의 weekday는 1(월요일)부터 7(일요일)까지, 배열 인덱스는 0부터 시작하므로 -1
    final dayIndex = (date.weekday - 1) % 7;
    return dayNames[dayIndex];
  }

  // 간단한 날짜 문자열 (MM.dd)
  String getShortDate() {
    return DateFormat('MM.dd').format(date);
  }

  // 모임 상태 확인 (예정/진행중/종료)
  String getStatus() {
    final now = DateTime.now();

    // 날짜와 시간 문자열을 결합하여 DateTime 객체 생성
    final meetupTimeStr = time.split('~')[0].trim(); // "14:00 ~ 16:00" => "14:00"
    final hour = int.tryParse(meetupTimeStr.split(':')[0]) ?? 0;
    final minute = int.tryParse(meetupTimeStr.split(':')[1]) ?? 0;

    final meetupDateTime = DateTime(
        date.year, date.month, date.day, hour, minute
    );

    // 종료 시간 추정 (시작으로부터 2시간 후로 가정)
    final endHour = (time.contains('~'))
        ? int.tryParse(time.split('~')[1].trim().split(':')[0]) ?? (hour + 2)
        : (hour + 2);
    final endMinute = (time.contains('~'))
        ? int.tryParse(time.split('~')[1].trim().split(':')[1]) ?? minute
        : minute;

    final meetupEndDateTime = DateTime(
        date.year, date.month, date.day, endHour, endMinute
    );

    if (now.isBefore(meetupDateTime)) {
      return '예정';
    } else if (now.isAfter(meetupEndDateTime)) {
      return '종료';
    } else {
      return '진행중';
    }
  }

  // 모임이 가득 찼는지 확인
  bool isFull() {
    return currentParticipants >= maxParticipants;
  }
}