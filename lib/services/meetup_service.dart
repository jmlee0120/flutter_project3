// lib/services/meetup_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meetup.dart';
import '../constants/app_constants.dart';
import 'notification_service.dart';

class MeetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // 현재 날짜부터 7일간의 날짜 계산 (오늘 포함)
  List<DateTime> getWeekDates() {
    final DateTime now = DateTime.now();
    final List<DateTime> weekDates = [];

    // 오늘 날짜를 시작으로 7일 생성
    final DateTime today = DateTime(now.year, now.month, now.day);

    // 오늘부터 6일 후까지 날짜 생성
    for (int i = 0; i < 7; i++) {
      weekDates.add(today.add(Duration(days: i)));
    }

    return weekDates;
  }

  // 날짜 포맷 문자열 반환 (요일도 포함)
  String getFormattedDate(DateTime date) {
    final List<String> weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final int weekdayIndex = date.weekday - 1;  // 0: 월요일, 6: 일요일
    return '${date.month}월 ${date.day}일 (${weekdayNames[weekdayIndex]})';
  }

  // 모임 생성
  Future<bool> createMeetup({
    required String title,
    required String description,
    required String location,
    required String time,
    required int maxParticipants,
    required DateTime date,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // 사용자 데이터 가져오기
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final nickname = userData?['nickname'] ?? '익명';

      // 모임 생성 시간
      final now = FieldValue.serverTimestamp();

      // 모임 데이터 생성
      final meetupData = {
        'userId': user.uid,
        'hostNickname': nickname,
        'title': title,
        'description': description,
        'location': location,
        'time': time,
        'maxParticipants': maxParticipants,
        'currentParticipants': 1,  // 주최자 포함
        'participants': [user.uid], // 주최자 ID
        'date': date,
        'createdAt': now,
        'updatedAt': now,
      };

      // Firestore에 저장
      await _firestore.collection('meetups').add(meetupData);
      return true;
    } catch (e) {
      print('모임 생성 오류: $e');
      return false;
    }
  }

  // 요일별 모임 가져오기
  Stream<List<Meetup>> getMeetupsByDay(int dayIndex) {
    // 해당 요일의 날짜 계산 (현재 날짜 기준)
    final List<DateTime> weekDates = getWeekDates();
    final DateTime targetDate = weekDates[dayIndex];

    // 날짜 범위 설정 (해당 날짜의 00:00:00부터 23:59:59까지)
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    return _firestore
        .collection('meetups')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Timestamp에서 DateTime으로 변환
        DateTime meetupDate;
        if (data['date'] is Timestamp) {
          meetupDate = (data['date'] as Timestamp).toDate();
        } else {
          // 기본값으로 현재 날짜 사용
          meetupDate = startOfDay;
        }

        return Meetup(
          id: doc.id, // ID를 문자열로 직접 사용
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? '',
          time: data['time'] ?? '',
          maxParticipants: data['maxParticipants'] ?? 0,
          currentParticipants: data['currentParticipants'] ?? 1,
          host: data['hostNickname'] ?? '익명',
          imageUrl: AppConstants.DEFAULT_IMAGE_URL,
          date: meetupDate,
        );
      }).toList();
    });
  }

  // 모임 목록 가져오기 (메모리 기반)
  List<List<Meetup>> getMeetupsByDayFromMemory() {
    // 현재 날짜 기준 일주일 날짜 계산
    final List<DateTime> weekDates = getWeekDates();

    return List.generate(
        7,
            (dayIndex) {
          // 해당 요일 날짜 가져오기
          final DateTime dayDate = weekDates[dayIndex];

          return [
            if (dayIndex == 0) ...[
              Meetup(
                id: "1", // String으로 변경
                title: '오왕러 커피에서 말자\n라떼 한 잔 어때세요?',
                description: '한강에서 함께 달려요! 초보자도 환영합니다.',
                location: '잠실한강공원',
                time: '18:00',
                maxParticipants: 3,
                currentParticipants: 3,
                host: '러너김',
                imageUrl: AppConstants.DEFAULT_IMAGE_URL,
                date: dayDate,
              ),
            ],
            if (dayIndex == 2) ...[
              Meetup(
                id: "3", // String으로 변경
                title: '수요일 코딩 스터디',
                description: 'Flutter 스터디 모임입니다. 기초부터 함께해요!',
                location: '선릉역 근처 스터디카페',
                time: '20:00',
                maxParticipants: 6,
                currentParticipants: 2,
                host: '개발자박',
                imageUrl: AppConstants.DEFAULT_IMAGE_URL,
                date: dayDate,
              ),
            ],
            if (dayIndex == 5) ...[
              Meetup(
                id: "5", // String으로 변경
                title: '주말 등산 모임',
                description: '북한산 등산! 도시락 챙겨오세요~',
                location: '북한산 국립공원 입구',
                time: '09:00',
                maxParticipants: 15,
                currentParticipants: 7,
                host: '산돌이',
                imageUrl: AppConstants.DEFAULT_IMAGE_URL,
                date: dayDate,
              ),
            ],
          ];
        }
    );
  }

  // 특정 요일에 해당하는 날짜 계산
  DateTime getDayDate(int dayIndex) {
    final List<DateTime> weekDates = getWeekDates();
    return weekDates[dayIndex];
  }

  // 모임 참여 (알림 기능 추가)
  Future<bool> joinMeetup(String meetupId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final meetupRef = _firestore.collection('meetups').doc(meetupId);

      // 트랜잭션 전에 모임 정보 미리 가져오기
      final meetupDoc = await meetupRef.get();
      if (!meetupDoc.exists) {
        print('모임 문서가 존재하지 않음: $meetupId');
        return false;
      }

      final data = meetupDoc.data()!;
      final hostId = data['userId'];
      final meetupTitle = data['title'];
      final maxParticipants = data['maxParticipants'] ?? 1;

      // bool 타입 반환하는 트랜잭션 실행
      bool success = await _firestore.runTransaction<bool>((transaction) async {
        // 트랜잭션 내부에서 다시 문서 가져오기 (최신 데이터 확보)
        final updatedDoc = await transaction.get(meetupRef);
        if (!updatedDoc.exists) return false;

        final updatedData = updatedDoc.data()!;
        final List<dynamic> participants = List.from(updatedData['participants'] ?? []);

        // 이미 참여 중인지 확인
        if (participants.contains(user.uid)) {
          print('이미 참여 중인 모임: $meetupId');
          return false;
        }

        // 정원 초과 확인
        final currentParticipants = updatedData['currentParticipants'] ?? 1;
        if (currentParticipants >= maxParticipants) {
          print('모임 정원 초과: $meetupId');
          return false;
        }

        // 참여자 추가
        participants.add(user.uid);

        // 참여자 수 업데이트
        final newParticipantCount = currentParticipants + 1;

        transaction.update(meetupRef, {
          'participants': participants,
          'currentParticipants': newParticipantCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true; // 트랜잭션 성공
      });

      // 트랜잭션 성공 및 정원이 다 찬 경우 알림 발송
      if (success) {
        // 현재 참여자 수 확인을 위해 다시 문서 조회
        final updatedDoc = await meetupRef.get();
        final currentParticipants = updatedDoc.data()?['currentParticipants'] ?? 1;

        if (currentParticipants >= maxParticipants) {
          // 모임 객체 생성
          final meetup = Meetup(
            id: meetupId,
            title: meetupTitle ?? '',
            description: '',  // 알림에 사용되지 않음
            location: '',     // 알림에 사용되지 않음
            time: '',         // 알림에 사용되지 않음
            maxParticipants: maxParticipants,
            currentParticipants: currentParticipants,
            host: '',         // 알림에 사용되지 않음
            imageUrl: '',     // 알림에 사용되지 않음
            date: DateTime.now(), // 알림에 사용되지 않음
          );

          // 모임 주최자에게 알림 전송
          await _notificationService.sendMeetupFullNotification(meetup, hostId);
        }
      }

      return success;
    } catch (e) {
      print('모임 참여 오류: $e');
      return false;
    }
  }

  //모임 삭제
  Future<bool> deleteMeetup(String meetupId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // 모임 문서 가져오기
      final meetupDoc = await _firestore.collection('meetups').doc(meetupId).get();

      // 문서가 없거나 사용자가 주최자가 아닌 경우
      if (!meetupDoc.exists) return false;

      final data = meetupDoc.data()!;
      if (data['userId'] != user.uid) {
        return false; // 현재 사용자가 주최자가 아니면 삭제 불가
      }

      // 모임 삭제
      await _firestore.collection('meetups').doc(meetupId).delete();
      return true;
    } catch (e) {
      print('모임 삭제 오류: $e');
      return false;
    }
  }

  // 사용자가 모임 주최자인지 확인
  Future<bool> isUserHostOfMeetup(String meetupId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final meetupDoc = await _firestore.collection('meetups').doc(meetupId).get();
      if (!meetupDoc.exists) return false;

      final data = meetupDoc.data()!;
      return data['userId'] == user.uid;
    } catch (e) {
      print('주최자 확인 오류: $e');
      return false;
    }
  }
}