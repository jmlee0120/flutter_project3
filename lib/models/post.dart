// lib/models/post.dart
class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final String userId;
  final int commentCount;
  final int likes;           // 좋아요 수
  final List<String> likedBy; // 좋아요 누른 사용자 ID 목록

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.userId,
    this.commentCount = 0,
    this.likes = 0,
    this.likedBy = const [],
  });

  // 게시글 생성 시간을 표시 형식으로 변환
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  // 미리보기용 내용 (최대 50자)
  String getPreviewContent() {
    if (content.length <= 50) {
      return content;
    }
    return '${content.substring(0, 50)}...';
  }

  // 현재 사용자가 이 게시글에 좋아요를 눌렀는지 확인
  bool isLikedByUser(String userId) {
    return likedBy.contains(userId);
  }
}