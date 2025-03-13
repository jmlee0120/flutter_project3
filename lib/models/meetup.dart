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
  final DateTime date; // 모임 날짜 추가

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
    required this.date, // 날짜 필드 추가
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
    DateTime? date, // 날짜 필드 추가
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
      date: date ?? this.date, // date 필드 복사
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
}