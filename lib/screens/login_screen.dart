// lib/screens/login_screen.dart
// 로그인 화면 구현
// Google 로그인 기능 제공
// 인증 후 화면 전환 처리



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/nickname_setup_screen.dart';
import '../screens/main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFF), // 연한 하늘색 배경
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 이름 텍스트
            const Text(
              'Wefilling',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800, // 굵직한 글씨체
                color: Colors.blueAccent, // 초록색 글씨
                fontFamily: 'Roboto', // 단단해 보이는 글씨체
                letterSpacing: 1.2, // 글자 간격을 약간 넓혀 더 단단해 보이게
              ),
            ),
            const SizedBox(height: 60),

            // Google 로그인 버튼 (이미지만 사용)
            InkWell(
              onTap: () async {
                try {
                  // 로딩 상태가 아닐 때만 로그인 시도
                  if (!authProvider.isLoading) {
                    // Google 로그인 처리
                    await authProvider.signInWithGoogle();

                    // 지연 추가 - 로그인 처리 시간 확보
                    await Future.delayed(const Duration(milliseconds: 1000));

                    if (context.mounted) {
                      // 로그인 성공 확인 (사용자 정보로 직접 확인)
                      if (authProvider.isLoggedIn) {
                        print("로그인 성공: ${authProvider.user?.email}");

                        // 닉네임 설정 여부에 따라 화면 전환
                        if (authProvider.hasNickname) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const NicknameSetupScreen()),
                          );
                        }
                      } else if (!authProvider.isLoading) {
                        // 로그인 실패 메시지
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  print("로그인 오류: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('로그인 중 오류가 발생했습니다: $e'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Image.asset(
                'assets/GoogleLogin.png', // 구글 로고 이미지
                height: 48,
                width: 240, // 버튼 이미지 전체의 너비
                errorBuilder: (context, error, stackTrace) {
                  // 이미지 로드 실패 시 대체 버튼
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.login, size: 24, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        const Text(
                          'Google로 로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 로딩 표시
            if (authProvider.isLoading) ...[
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}