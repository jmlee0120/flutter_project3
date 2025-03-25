// lib/screens/user_posts_screen.dart
// 마이페이지에서 게시글 목록 확인 용도


import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/user_stats_service.dart';
import 'post_detail_screen.dart';

class UserPostsScreen extends StatefulWidget {
  const UserPostsScreen({Key? key}) : super(key: key);

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  final UserStatsService _userStatsService = UserStatsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 게시글'),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _userStatsService.getUserPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text('작성한 게시글이 없습니다'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 게시글 수 표시 부분 추가
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      '총 ${posts.length}개의 게시글',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // 여기에 필요시 정렬 옵션 추가 가능
                  ],
                ),
              ),

              const Divider(),

              // 게시글 목록
              Expanded(
                child: ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      title: Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.getPreviewContent(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                post.getFormattedTime(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              // 좋아요 표시
                              if (post.likes > 0)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 14,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.likes}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(width: 8),
                              // 댓글 수 표시
                              if (post.commentCount > 0)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 14,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.commentCount}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post: post),
                          ),
                        ).then((value) {
                          // 게시글 상세 화면에서 돌아올 때 목록 갱신
                          if (value == true) {
                            setState(() {});
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}