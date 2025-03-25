// lib/services/auth_service.dart
// 인증관련 기능 제공(로그인, 로그아웃, 사용자 정보 관리)
// Google 로그인 구현
// 사용자 프로필 정보 저장 및 검색
// 닉네임 업데이트 기능



import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 로그인된 사용자
  User? get currentUser => _auth.currentUser;

  // 사용자 상태 변경 감지
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 구글 로그인 Flow 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      // 사용자 정보 Firestore에 저장
      await _storeUserData(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('구글 로그인 오류: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 사용자 정보 Firestore에 저장
  Future<void> _storeUserData(User user) async {
    // 사용자 문서 참조
    final userDoc = _firestore.collection('users').doc(user.uid);

    // 문서가 이미 존재하는지 확인
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // 새 사용자면 기본 정보 저장
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'nickname': '', // 사용자가 나중에 설정할 닉네임
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // 닉네임 업데이트
  Future<void> updateNickname(String nickname) async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'nickname': nickname,
      });
    }
  }

  // 사용자 프로필 정보 가져오기
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser != null) {
      final docSnapshot = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    }
    return null;
  }
}