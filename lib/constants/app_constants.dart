// lib/constants/app_constants.dart
// Update the JOIN and FULL constants

// 앱 전체에서 사용하는 상수 정의
// 문자열, 기본값 등 관리

class AppConstants {
  // Meetup related
  static const String JOIN = "Join";
  static const String FULL = "End";
  static const String JOINED_MEETUP = "에 참여 신청이 완료되었습니다!";
  static const String CREATE_MEETUP = "모임 만들기";
  static const String NO_MEETUPS = "등록된 모임이 없습니다";

  // Default values
  static const String DEFAULT_HOST = "익명";
  static const String DEFAULT_IMAGE_URL = "assets/default_meetup.jpg";
  static const int DEFAULT_MAX_PARTICIPANTS = 4;

  // Form labels
  static const String FORM_TITLE = "모임 제목";
  static const String FORM_DESCRIPTION = "모임 설명";
  static const String FORM_LOCATION = "장소";
  static const String FORM_TIME = "시간";
  static const String FORM_DAY = "날짜";
  static const String FORM_MAX_PARTICIPANTS = "최대 인원";

  // Form validation errors
  static const String FORM_TITLE_ERROR = "모임 제목을 입력해주세요";

  // Button labels
  static const String CANCEL = "취소";
  static const String CREATE = "만들기";

  // Tab labels
  static const String BOARD = "게시판";
  static const String MEETUP = "모임";
  static const String MYPAGE = "내 정보";
}