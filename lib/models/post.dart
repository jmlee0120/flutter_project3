// lib/models/post.dart
class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final String userId;
  final int commentCount; // 댓글 개수 필드 추가

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.userId,
    this.commentCount = 0, // 기본값 0
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
}