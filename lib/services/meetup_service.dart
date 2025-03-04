import '../models/meetup.dart';

class MeetupService {
  // 모임 데이터 모델 초기화
  List<List<Meetup>> getMeetupsByDay() {
    final DateTime now = DateTime.now();

    // 이번 주 시작일 계산 (월요일부터 시작)
    final int weekday = now.weekday; // 1(월요일)~7(일요일)
    final DateTime weekStart = now.subtract(Duration(days: weekday - 1));

    return List.generate(
        7,
            (dayIndex) {
          // 해당 요일 날짜 계산
          final DateTime dayDate = weekStart.add(Duration(days: dayIndex));

          return [
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
                date: dayDate,
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
                date: dayDate,
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
                date: dayDate,
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
                date: dayDate,
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
                date: dayDate,
              ),
            ],
          ];
        }
    );
  }

  // 새로운 모임 추가 메서드
  void addMeetup(List<List<Meetup>> meetupsByDay, int dayIndex, Meetup newMeetup) {
    meetupsByDay[dayIndex].add(newMeetup);
  }

  // 모임 참여 메서드
  void joinMeetup(List<List<Meetup>> meetupsByDay, int dayIndex, Meetup meetup) {
    final index = meetupsByDay[dayIndex].indexWhere((m) => m.id == meetup.id);
    if (index != -1) {
      meetupsByDay[dayIndex][index] = meetup.copyWith(
        currentParticipants: meetup.currentParticipants + 1,
      );
    }
  }

  // 특정 요일에 해당하는 날짜 생성
  DateTime getDayDate(int dayIndex) {
    final DateTime now = DateTime.now();
    final int weekday = now.weekday; // 1(월요일)~7(일요일)
    final DateTime weekStart = now.subtract(Duration(days: weekday - 1));
    return weekStart.add(Duration(days: dayIndex));
  }
}