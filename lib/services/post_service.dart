// lib/services/post_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 게시글 추가
  Future<void> addPost(String title, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 사용자 데이터 가져오기
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final nickname = userData?['nickname'] ?? '익명';

      // 게시글 작성 시간
      final now = FieldValue.serverTimestamp();

      // 게시글 데이터 생성
      final postData = {
        'userId': user.uid,
        'authorNickname': nickname,
        'title': title,
        'content': content,
        'createdAt': now,
        'updatedAt': now,
        'likes': 0,
        'comments': [],
        'commentCount': 0, // 댓글 개수 초기값 추가
      };

      // Firestore에 저장
      await _firestore.collection('posts').add(postData);
    } catch (e) {
      print('게시글 작성 오류: $e');
      rethrow; // 오류를 상위 호출자에게 전파
    }
  }

  // 모든 게시글 가져오기 (추가된 메서드)
  Stream<List<Post>> getAllPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: data['authorNickname'] ?? '익명',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          userId: data['userId'] ?? '',
          commentCount: data['commentCount'] ?? 0, // 댓글 개수 필드 추가
        );
      }).toList();
    });
  }

  // 특정 게시글 가져오기
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Post(
        id: doc.id,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        author: data['authorNickname'] ?? '익명',
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        userId: data['userId'] ?? '',
        commentCount: data['commentCount'] ?? 0, // 댓글 개수 추가
      );
    } catch (e) {
      print('게시글 조회 오류: $e');
      return null;
    }
  }

  // 게시글 삭제
  Future<bool> deletePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('삭제 실패: 로그인이 필요합니다.');
        return false;
      }

      // 게시글 문서 가져오기
      final postDoc = await _firestore.collection('posts').doc(postId).get();

      // 문서가 없는 경우
      if (!postDoc.exists) {
        print('삭제 실패: 게시글이 존재하지 않습니다.');
        return false;
      }

      final data = postDoc.data()!;

      // 현재 사용자가 작성자인지 확인
      if (data['userId'] != user.uid) {
        print('삭제 실패: 게시글 작성자만 삭제할 수 있습니다.');
        return false;
      }

      // 게시글 삭제
      await _firestore.collection('posts').doc(postId).delete();
      print('게시글 삭제 성공: $postId');
      return true;
    } catch (e) {
      print('게시글 삭제 오류: $e');
      return false;
    }
  }

  // 현재 사용자가 게시글 작성자인지 확인
  Future<bool> isCurrentUserAuthor(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) return false;

      final data = postDoc.data()!;
      return data['userId'] == user.uid;
    } catch (e) {
      print('작성자 확인 오류: $e');
      return false;
    }
  }
}