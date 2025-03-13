// lib/screens/nickname_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class NicknameSetupScreen extends StatefulWidget {
  const NicknameSetupScreen({Key? key}) : super(key: key);

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  String _selectedNationality = '한국'; // 기본값

  // 국적 목록 (필요에 따라 확장)
  final List<String> _nationalities = [
    '한국', '미국', '일본', '중국', '영국', '프랑스', '독일', '캐나다', '호주', '기타'
  ];

  // 폼 제출
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.updateUserProfile(
        nickname: _nicknameController.text.trim(),
        nationality: _selectedNationality,
      );
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFF), // 연한 하늘색 배경
      appBar: AppBar(
        title: const Text('프로필 설정'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // 안내 텍스트
              const Text(
                '환영합니다! 프로필을 설정해주세요.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 닉네임 입력
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  hintText: '사용할 닉네임을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  if (value.length < 2 || value.length > 20) {
                    return '닉네임은 2~20자 사이로 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 국적 선택
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '국적',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedNationality,
                items: _nationalities.map((nationality) {
                  return DropdownMenuItem(
                    value: nationality,
                    child: Text(nationality),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedNationality = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 40),

              // 제출 버튼
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}