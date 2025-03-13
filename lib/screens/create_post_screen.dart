import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/post_service.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostScreen extends StatefulWidget {
  final Function onPostCreated;

  const CreatePostScreen({
    super.key,
    required this.onPostCreated,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _postService = PostService();

  bool _isSubmitting = false;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    // 텍스트 컨트롤러에 리스너 추가
    _titleController.addListener(_checkCanSubmit);
    _contentController.addListener(_checkCanSubmit);
  }

  // 제목과 본문이 모두 입력되었는지 확인
  void _checkCanSubmit() {
    final titleNotEmpty = _titleController.text.trim().isNotEmpty;
    final contentNotEmpty = _contentController.text.trim().isNotEmpty;

    setState(() {
      _canSubmit = titleNotEmpty && contentNotEmpty;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Firebase에 게시글 저장
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        final userData = authProvider.userData;
        final nickname = userData?['nickname'] ?? '익명';

        // Firestore에 게시글 저장
        await FirebaseFirestore.instance.collection('posts').add({
          'userId': user?.uid,
          'authorNickname': nickname,
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 게시글 추가 완료 후 콜백 호출
        widget.onPostCreated();

        // 화면 닫기
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글이 등록되었습니다.')),
          );
        }
      } catch (e) {
        print('게시글 작성 오류: $e');
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글 등록에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 유저의 닉네임 가져오기
    final authProvider = Provider.of<AuthProvider>(context);
    final nickname = authProvider.userData?['nickname'] ?? '익명';

    return Scaffold(
      appBar: AppBar(
        title: const Text('새 게시글 작성'),
        actions: [
          TextButton(
            onPressed: (_canSubmit && !_isSubmitting) ? _submitPost : null,
            child: Text(
              'Post',
              style: TextStyle(
                color: _canSubmit ? Colors.red : Colors.grey[400],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작성자 정보 표시
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '작성자: $nickname',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '내용을 입력해주세요';
                    }
                    return null;
                  },
                ),
              ),
              // 로딩 표시
              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}