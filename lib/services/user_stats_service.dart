// lib/services/user_stats_service.dart
// 사용자 활동 통계 관리
// 참여 모임, 작성 게시글, 받은 좋아요 통계 제공
// 사용자별 콘텐츠 필터링 및 조회



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../models/meetup.dart';

class UserStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 사용자가 주최한 모임 수
  Stream<int> getHostedMeetupCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('meetups')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 사용자가 참여한 모임 수 (주최한 모임 제외)
  Stream<int> getJoinedMeetupCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('meetups')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
      // 주최하지 않은 모임만 필터링
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['userId'] != user.uid;
      }).toList();

      return filteredDocs.length;
    });
  }

  // 사용자가 주최한 모임 목록
  Stream<List<Meetup>> getHostedMeetups() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('meetups')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final meetupDate = data['date'] != null
            ? (data['date'] as Timestamp).toDate()
            : DateTime.now();

        return Meetup(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? '',
          time: data['time'] ?? '',
          maxParticipants: data['maxParticipants'] ?? 0,
          currentParticipants: data['currentParticipants'] ?? 0,
          host: data['hostNickname'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          date: meetupDate,
        );
      }).toList();
    });
  }

  // 사용자가 참여했던 모임 목록 (주최한 모임 제외)
  Stream<List<Meetup>> getJoinedMeetups() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('meetups')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
      try {
        // 사용자가 주최하지 않은 모임만 필터링
        final filteredDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          // 'userId' 필드가 존재하고, 현재 사용자 ID와 다른 경우
          return data['userId'] != user.uid;
        }).toList();

        // 필터링된 결과가 없을 경우 빈 배열 반환
        if (filteredDocs.isEmpty) {
          return <Meetup>[];
        }

        return filteredDocs.map((doc) {
          final data = doc.data();
          final meetupDate = data['date'] != null
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now();

          return Meetup(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            location: data['location'] ?? '',
            time: data['time'] ?? '',
            maxParticipants: data['maxParticipants'] ?? 0,
            currentParticipants: data['currentParticipants'] ?? 0,
            host: data['hostNickname'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            date: meetupDate,
          );
        }).toList();
      } catch (e) {
        print('참여 모임 처리 오류: $e');
        return <Meetup>[];
      }
    });
  }

  // 사용자가 작성한 게시글 수
  Stream<int> getUserPostCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 사용자가 작성한 게시글 목록
  Stream<List<Post>> getUserPosts() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: data['authorNickname'] ?? '',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          userId: data['userId'] ?? '',
          likes: (data['likes'] ?? 0).toInt(),
          likedBy: List<String>.from(data['likedBy'] ?? []),
          commentCount: (data['commentCount'] ?? 0).toInt(),
        );
      }).toList();
    });
  }

  // 사용자가 받은 좋아요 총수
  Stream<int> getUserTotalLikes() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      int totalLikes = 0;
      for (var doc in snapshot.docs) {
        totalLikes += (doc.data()['likes'] as num? ?? 0).toInt();
      }
      return totalLikes;
    });
  }

  // 사용자가 좋아요를 받은 게시글 목록
  Stream<List<Post>> getLikedPosts() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: user.uid)
        .where('likes', isGreaterThan: 0)
        .orderBy('likes', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: data['authorNickname'] ?? '',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          userId: data['userId'] ?? '',
          likes: (data['likes'] ?? 0).toInt(),
          likedBy: List<String>.from(data['likedBy'] ?? []),
          commentCount: (data['commentCount'] ?? 0).toInt(),
        );
      }).toList();
    });
  }
}