// lib/models/post.dart
// 게시글 데이터 모델 정의
// 게시글 관련 속성 및 메서드 포함(제목,내용,작성자,작성일,좋아요 수 등)
// 데이터 포맷팅 메서드 제공(날짜, 미리보기 등)

import 'package:intl/intl.dart';

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

    if (difference.inDays > 7) {
      // 일주일 이상 지난 경우 날짜 표시
      return DateFormat('yyyy.MM.dd').format(createdAt);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // 미리보기용 내용 (최대 100자)
  String getPreviewContent() {
    if (content.length <= 100) {
      return content;
    }
    return '${content.substring(0, 100)}...';
  }

  // 현재 사용자가 이 게시글에 좋아요를 눌렀는지 확인
  bool isLikedByUser(String userId) {
    return likedBy.contains(userId);
  }

  // Post 객체 복제 메서드 (필요시 데이터 업데이트에 사용)
  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    DateTime? createdAt,
    String? userId,
    int? commentCount,
    int? likes,
    List<String>? likedBy,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      commentCount: commentCount ?? this.commentCount,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}