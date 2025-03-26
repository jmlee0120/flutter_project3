// lib/services/comment_service.dart
// 댓글 관련 CRUD 작업 처리
// 게시글에 댓글 추가 및 삭제
// 댓글 수 관리


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment.dart';
import 'notification_service.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // 댓글 추가
  Future<bool> addComment(String postId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('댓글 작성 실패: 로그인이 필요합니다.');
        return false;
      }

      // 사용자 데이터 가져오기
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final nickname = userData?['nickname'] ?? '익명';
      final photoUrl = userData?['photoURL'] ?? user.photoURL ?? '';

      // 댓글 데이터 생성
      final commentData = {
        'postId': postId,
        'userId': user.uid,
        'authorNickname': nickname,
        'authorPhotoUrl': photoUrl,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Firestore에 저장
      await _firestore.collection('comments').add(commentData);

      // 게시글 정보 가져오기 (제목과 작성자 ID 필요)
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (postDoc.exists && postDoc.data() != null) {
        final postData = postDoc.data()!;
        final postTitle = postData['title'] ?? '게시글';
        final postAuthorId = postData['userId'];

        // 게시글 작성자에게 알림 전송 (자기 자신이 댓글을 단 경우 제외)
        if (postAuthorId != null && postAuthorId != user.uid) {
          await _notificationService.sendNewCommentNotification(
              postId,
              postTitle,
              postAuthorId,
              nickname,
              user.uid
          );
        }
      }

      // 게시글 문서에 댓글 수 업데이트
      await _updateCommentCount(postId);

      return true;
    } catch (e) {
      print('댓글 작성 오류: $e');
      return false;
    }
  }

  // 게시글의 댓글 수 업데이트
  Future<void> _updateCommentCount(String postId) async {
    try {
      // 해당 게시글의 댓글 수 계산
      final querySnapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();

      final commentCount = querySnapshot.docs.length;

      // 게시글 문서 업데이트
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': commentCount,
      });
    } catch (e) {
      print('댓글 수 업데이트 오류: $e');
    }
  }

  // 게시글의 모든 댓글 가져오기
  Stream<List<Comment>> getCommentsByPostId(String postId) {
    try {
      return _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
      // 정렬 부분 제거 - 인덱스 문제의 원인
      // .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        List<Comment> comments = snapshot.docs.map((doc) {
          return Comment.fromFirestore(doc);
        }).toList();

        // 클라이언트 측에서 정렬 수행
        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return comments;
      });
    } catch (e) {
      print('댓글 불러오기 오류: $e');
      // 오류 발생 시 빈 리스트 반환
      return Stream.value([]);
    }
  }

  // 댓글 삭제
  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('댓글 삭제 실패: 로그인이 필요합니다.');
        return false;
      }

      // 댓글 문서 가져오기
      final commentDoc = await _firestore.collection('comments').doc(commentId).get();

      // 문서가 없는 경우
      if (!commentDoc.exists) {
        print('댓글 삭제 실패: 댓글이 존재하지 않습니다.');
        return false;
      }

      final data = commentDoc.data()!;

      // 현재 사용자가 작성자인지 확인
      if (data['userId'] != user.uid) {
        print('댓글 삭제 실패: 댓글 작성자만 삭제할 수 있습니다.');
        return false;
      }

      // 댓글 삭제
      await _firestore.collection('comments').doc(commentId).delete();

      // 게시글 문서의 댓글 수 업데이트
      await _updateCommentCount(postId);

      return true;
    } catch (e) {
      print('댓글 삭제 오류: $e');
      return false;
    }
  }
}