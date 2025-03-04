class AppConstants {
  // 요일 상수
  static const List<String> DAYS = ['월', '화', '수', '목', '금', '토', '일'];
  static const List<String> DAY_LABELS = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

  // 네비게이션 아이템
  static const String BOARD = '게시판';
  static const String MEETUP = '모임';
  static const String MYPAGE = '마이페이지';

  // 기본 텍스트
  static const String APP_TITLE = '요일별 모임';
  static const String BOARD_TITLE = '게시판';
  static const String MYPAGE_TITLE = '마이페이지';
  static const String NO_MEETUPS = '아직 모임이 없습니다';
  static const String CREATE_MEETUP = '새 모임 만들기';
  static const String SEARCH_NOT_READY = '검색 기능은 준비 중입니다.';
  static const String CREATE_MEETUP_NOT_READY = '새 모임 만들기 기능은 준비 중입니다.';
  static const String JOINED_MEETUP = '에 참여했습니다!';
  static const String FULL = '정원 마감';
  static const String JOIN = '참여하기';
  static const String COMING_SOON = '준비 중입니다';

  // 폼 라벨
  static const String FORM_DAY = '요일';
  static const String FORM_TITLE = '모임 제목';
  static const String FORM_DESCRIPTION = '모임 설명';
  static const String FORM_LOCATION = '장소';
  static const String FORM_TIME = '시간';
  static const String FORM_MAX_PARTICIPANTS = '최대 참가 인원';
  static const String FORM_TITLE_ERROR = '제목을 입력해주세요';

  // 다이얼로그 버튼
  static const String CANCEL = '취소';
  static const String CREATE = '만들기';

  // 모임 카드 라벨
  static const String HOST = '주최자: ';

  // 디폴트 값
  static const int DEFAULT_MAX_PARTICIPANTS = 5;
  static const String DEFAULT_HOST = '나';
  static const String DEFAULT_IMAGE_URL = 'https://via.placeholder.com/150';
}