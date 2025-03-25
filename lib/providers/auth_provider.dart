// lib/providers/auth_provider.dart
// 인증상태 관리 및 전파
// 로그인 상태, 사용자 정보 제공
// 다른 화면에서 인증 정보 접근 가능하게 함


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  AuthProvider() {
    _initializeAuth();
  }

  // 초기화 함수 분리
  Future<void> _initializeAuth() async {
    // 먼저 현재 사용자 확인
    _user = _auth.currentUser;

    // 사용자 인증 상태 변화 감지
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        // 사용자 데이터 가져오기
        await _loadUserData();
      } else {
        _userData = null;
        _isLoading = false;
        notifyListeners();
      }
    });

    // 이미 로그인되어 있다면 데이터 로드
    if (_user != null) {
      await _loadUserData();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 정보
  User? get user => _user;

  // 로딩 상태
  bool get isLoading => _isLoading;

  // 로그인 여부
  bool get isLoggedIn => _user != null;

  // 닉네임 설정 여부
  bool get hasNickname => _userData != null && _userData!.containsKey('nickname') && _userData!['nickname'] != null;

  // 사용자 데이터 (닉네임, 국적 등)
  Map<String, dynamic>? get userData => _userData;

  // 사용자 데이터 로드
  Future<void> _loadUserData() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        // 문서가 없으면 기본 문서 생성
        await _checkAndCreateUserDocument();
        // 다시 로드 시도
        final newDoc = await _firestore.collection('users').doc(_user!.uid).get();
        _userData = newDoc.exists ? newDoc.data() : null;
      }
    } catch (e) {
      print('사용자 데이터 로드 오류: $e');
      _userData = null;
    }

    _isLoading = false;
    notifyListeners();
  }



// 구글 로그인
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 기존 로그인 세션 초기화
      await _googleSignIn.signOut();

      // 구글 로그인 다이얼로그
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // 사용자가 로그인 취소
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Firebase 인증용 크레덴셜 생성
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 로그인
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // 사용자 정보 업데이트
      _user = userCredential.user;

      // 사용자 정보 Firebase 저장
      if (_user != null) {
        await _checkAndCreateUserDocument();
        await _loadUserData();
      }

      return _user != null;
    } catch (e) {
      print('구글 로그인 오류: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 사용자 문서 확인 및 생성
  Future<void> _checkAndCreateUserDocument() async {
    if (_user == null) return;

    try {
      final docRef = _firestore.collection('users').doc(_user!.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // 사용자 기본 정보 설정
        await docRef.set({
          'email': _user!.email,
          'displayName': _user!.displayName,
          'photoURL': _user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // 기존 사용자 마지막 로그인 시간 업데이트
        await docRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('사용자 문서 생성 오류: $e');
    }
  }

  // 닉네임 설정
  Future<bool> updateNickname(String nickname) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(_user!.uid).update({
        'nickname': nickname,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();
      return true;
    } catch (e) {
      print('닉네임 업데이트 오류: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 닉네임 및 국적 설정
  Future<bool> updateUserProfile({
    required String nickname,
    required String nationality,
  }) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(_user!.uid).update({
        'nickname': nickname,
        'nationality': nationality,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();
      return true;
    } catch (e) {
      print('프로필 업데이트 오류: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      _userData = null;
      notifyListeners();
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }
}