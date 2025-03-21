// lib/screens/mypage_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_practice3/screens/user_meetups_screens.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_stats_service.dart';
//import 'user_meetups_screens.dart';
import 'user_posts_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final UserStatsService _userStatsService = UserStatsService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userData = authProvider.userData;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 헤더
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 프로필 이미지
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue[100],
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Text(
                          userData?['nickname']?.substring(0, 1) ?? 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // 사용자 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData?['nickname'] ?? '사용자',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userData?['nationality'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 받은 좋아요 개수 표시 추가
                            StreamBuilder<int>(
                              stream: _userStatsService.getUserTotalLikes(),
                              builder: (context, snapshot) {
                                final likeCount = snapshot.data ?? 0;
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 16,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'x$likeCount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 자기소개 (선택적)
                  if (userData?['bio'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      userData!['bio'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],

                  // 프로필 편집 버튼
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // 프로필 편집 화면으로 이동 (구현 예정)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('프로필 편집 기능은 준비 중입니다.'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('프로필 편집'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // 활동 통계 - 실시간 데이터 연동 (숫자만 표시)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 주최한 모임 통계
                  StreamBuilder<int>(
                    stream: _userStatsService.getHostedMeetupCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _buildStatDisplay('주최한 모임', count.toString());
                    },
                  ),

                  // 참여했던 모임 통계
                  StreamBuilder<int>(
                    stream: _userStatsService.getJoinedMeetupCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _buildStatDisplay('참여했던 모임', count.toString());
                    },
                  ),

                  // 작성 게시글 통계
                  StreamBuilder<int>(
                    stream: _userStatsService.getUserPostCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _buildStatDisplay('작성 게시글', count.toString());
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // 메뉴 항목들
            _buildMenuItem(
              context,
              '내 모임',
              Icons.group,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserMeetupsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              '내 게시글',
              Icons.article,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserPostsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              '알림 설정',
              Icons.notifications,
                  () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('준비 중인 기능입니다.')),
              ),
            ),
            _buildMenuItem(
              context,
              '계정 설정',
              Icons.settings,
                  () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('준비 중인 기능입니다.')),
              ),
            ),

            const Divider(),

            // 로그아웃 버튼
            _buildMenuItem(
              context,
              '로그아웃',
              Icons.logout,
                  () async {
                await authProvider.signOut();
              },
              color: Colors.red,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 클릭 불가능한 통계 표시 위젯
  Widget _buildStatDisplay(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 메뉴 아이템 위젯
  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap, {
        Color? color,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.black87, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color ?? Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}