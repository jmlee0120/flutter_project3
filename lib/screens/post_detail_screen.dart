// lib/screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';
import '../providers/auth_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostService _postService = PostService();
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  bool _isAuthor = false;
  bool _isDeleting = false;
  bool _isSubmittingComment = false;
  bool _isLiked = false;
  bool _isTogglingLike = false;
  late Post _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _checkIfUserIsAuthor();
    _checkIfUserLikedPost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkIfUserIsAuthor() async {
    final isAuthor = await _postService.isCurrentUserAuthor(widget.post.id);
    if (mounted) {
      setState(() {
        _isAuthor = isAuthor;
      });
    }
  }

  Future<void> _checkIfUserLikedPost() async {
    final hasLiked = await _postService.hasUserLikedPost(widget.post.id);
    if (mounted) {
      setState(() {
        _isLiked = hasLiked;
      });
    }
  }

  // 게시글 새로고침
  Future<void> _refreshPost() async {
    try {
      final updatedPost = await _postService.getPostById(widget.post.id);
      if (updatedPost != null && mounted) {
        setState(() {
          _currentPost = updatedPost;
        });
      }
    } catch (e) {
      print('게시글 새로고침 오류: $e');
    }
  }

  // post_detail_screen.dart 파일의 _toggleLike 메서드 개선
  Future<void> _toggleLike() async {
    if (_isTogglingLike) return;

    // 로그인 상태 확인
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn;
    final user = authProvider.user;

    if (!isLoggedIn || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요를 누르려면 로그인이 필요합니다.')),
      );
      return;
    }

    // 즉시 UI 업데이트 (낙관적 업데이트 방식)
    setState(() {
      _isTogglingLike = true;
      _isLiked = !_isLiked; // 즉시 좋아요 상태 토글

      // 좋아요 수와 목록 업데이트
      if (_isLiked) {
        // 좋아요 추가
        _currentPost = Post(
          id: _currentPost.id,
          title: _currentPost.title,
          content: _currentPost.content,
          author: _currentPost.author,
          createdAt: _currentPost.createdAt,
          userId: _currentPost.userId,
          commentCount: _currentPost.commentCount,
          likes: _currentPost.likes + 1,
          likedBy: [..._currentPost.likedBy, user.uid],
        );
      } else {
        // 좋아요 제거
        _currentPost = Post(
          id: _currentPost.id,
          title: _currentPost.title,
          content: _currentPost.content,
          author: _currentPost.author,
          createdAt: _currentPost.createdAt,
          userId: _currentPost.userId,
          commentCount: _currentPost.commentCount,
          likes: _currentPost.likes - 1,
          likedBy: _currentPost.likedBy.where((id) => id != user.uid).toList(),
        );
      }
    });

    try {
      // Firebase에 변경사항 저장
      final success = await _postService.toggleLike(_currentPost.id);

      if (!success && mounted) {
        // 실패 시 UI 롤백
        setState(() {
          _isLiked = !_isLiked;
          // 좋아요 수와 목록 롤백
          if (_isLiked) {
            _currentPost = Post(
              id: _currentPost.id,
              title: _currentPost.title,
              content: _currentPost.content,
              author: _currentPost.author,
              createdAt: _currentPost.createdAt,
              userId: _currentPost.userId,
              commentCount: _currentPost.commentCount,
              likes: _currentPost.likes + 1,
              likedBy: [..._currentPost.likedBy, user.uid],
            );
          } else {
            _currentPost = Post(
              id: _currentPost.id,
              title: _currentPost.title,
              content: _currentPost.content,
              author: _currentPost.author,
              createdAt: _currentPost.createdAt,
              userId: _currentPost.userId,
              commentCount: _currentPost.commentCount,
              likes: _currentPost.likes - 1,
              likedBy: _currentPost.likedBy.where((id) => id != user.uid).toList(),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('좋아요 업데이트에 실패했습니다.')),
          );
        });
      }

      // 최신 데이터로 백그라운드 갱신 (필요한 경우)
      if (success) {
        _refreshPost();
      }
    } catch (e) {
      print('좋아요 토글 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingLike = false;
        });
      }
    }
  }

  Future<void> _deletePost() async {
    // 삭제 확인 다이얼로그 표시
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldDelete || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await _postService.deletePost(widget.post.id);

      if (success && mounted) {
        // 삭제 성공 시 화면 닫기
        Navigator.of(context).pop(true); // true를 반환하여 삭제되었음을 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 삭제되었습니다.')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글 삭제에 실패했습니다.')),
        );
        setState(() {
          _isDeleting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // 댓글 등록
  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      final success = await _commentService.addComment(widget.post.id, content);

      if (success && mounted) {
        _commentController.clear();
        // 키보드 닫기
        FocusScope.of(context).unfocus();

        // 게시글 정보 새로고침 (댓글 수 업데이트)
        await _refreshPost();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 등록에 실패했습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  // 댓글 삭제
  Future<void> _deleteComment(String commentId) async {
    try {
      final success = await _commentService.deleteComment(commentId, widget.post.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 삭제되었습니다.')),
        );

        // 게시글 정보 새로고침 (댓글 수 업데이트)
        await _refreshPost();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 삭제에 실패했습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 댓글 위젯 빌드
  Widget _buildCommentItem(Comment comment) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isCommentAuthor = authProvider.user?.uid == comment.userId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: comment.authorPhotoUrl.isNotEmpty
                ? NetworkImage(comment.authorPhotoUrl)
                : null,
            child: comment.authorPhotoUrl.isEmpty
                ? Text(
              comment.authorNickname.isNotEmpty
                  ? comment.authorNickname[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),

          // 댓글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 닉네임
                    Text(
                      comment.authorNickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 작성 시간
                    Text(
                      _formatNotificationTime(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 댓글 내용
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // 삭제 버튼 (댓글 작성자만 볼 수 있음)
          if (isCommentAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.red[300],
              onPressed: () => _deleteComment(comment.id),
              tooltip: '댓글 삭제',
            ),
        ],
      ),
    );
  }

  // 알림 시간 포맷팅
  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
        appBar: AppBar(
          title: const Text('게시글'),
        ),
        body: Column(
          children: [
            // 게시글 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 게시글 제목 및 작성자 정보
                    Text(
                      _currentPost.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _currentPost.author,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentPost.getFormattedTime(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // 게시글 본문
                    Text(
                      _currentPost.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    // 좋아요 섹션
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // 좋아요 버튼
                        IconButton(
                          icon: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : Colors.grey,
                            size: 28, // 버튼 크기 증가
                          ),
                          onPressed: _isTogglingLike ? null : () {
                            // 버튼 클릭 시 좋아요 토글 함수 호출
                            _toggleLike();
                          },
                          splashColor: Colors.red.withOpacity(0.3), // 눌렀을 때 효과 추가
                          splashRadius: 24,
                        ),
                        // 좋아요 수
                        Text(
                          '${_currentPost.likes}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isLiked ? Colors.red : Colors.grey[700],
                            fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        // 댓글 아이콘 및 수
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_currentPost.commentCount}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    // 댓글 섹션 타이틀
                    const SizedBox(height: 16),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '댓글',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // 댓글 목록
                    StreamBuilder<List<Comment>>(
                      stream: _commentService.getCommentsByPostId(_currentPost.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('댓글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}'),
                          );
                        }

                        final comments = snapshot.data ?? [];

                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('첫 번째 댓글을 남겨보세요!'),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _buildCommentItem(comments[index]);
                          },
                        );
                      },
                    ),

                    // 게시글 삭제 버튼을 위한 여백
                    if (_isAuthor)
                      const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // 댓글 입력 영역
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                  children: [
                  // 현재 사용자 프로필 이미지 (로그인 상태인 경우에만)
                  if (isLoggedIn) ...[
              CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              backgroundImage: authProvider.user?.photoURL != null
                  ? NetworkImage(authProvider.user!.photoURL!)
                  : null,
              child: authProvider.user?.photoURL == null
                  ? Text(
                authProvider.userData?['nickname'] != null
                    ? (authProvider.userData!['nickname'] as String)[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 8),
          ],

          // 댓글 입력 필드
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: isLoggedIn ? '댓글을 입력하세요...' : '로그인 후 댓글을 작성할 수 있습니다',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                enabled: isLoggedIn,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: isLoggedIn ? (_) => _submitComment() : null,
            ),
          ),

          // 댓글 전송 버튼
          const SizedBox(width: 8),
          IconButton(
          icon: _isSubmittingComment
          ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.send),
            onPressed: (isLoggedIn && !_isSubmittingComment)
                ? _submitComment
                : null,
            color: Colors.blue,
          ),
                  ],
              ),
            ),
          ],
        ),

      // 게시글 삭제 버튼 (작성자인 경우에만)
      floatingActionButton: _isAuthor
          ? FloatingActionButton(
        onPressed: _isDeleting ? null : _deletePost,
        backgroundColor: Colors.red,
        child: _isDeleting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Delete',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }
}