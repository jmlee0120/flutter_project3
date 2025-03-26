// lib/screens/notification_settings_screen.dart
// 알림 설정 화면
// 알림 유형별 ON/OFF 설정 기능 제공

import 'package:flutter/material.dart';
import '../services/notification_settings_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _notificationSettingsService = NotificationSettingsService();
  bool _isLoading = true;
  Map<String, bool> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = await _notificationSettingsService.getNotificationSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정을 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      // 즉시 UI 업데이트 (낙관적 업데이트)
      setState(() {
        _settings[key] = value;
      });

      // 설정 저장
      await _notificationSettingsService.updateNotificationSetting(key, value);
    } catch (e) {
      // 에러 발생시 원래 값으로 되돌림
      setState(() {
        _settings[key] = !value;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정을 저장하는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          // 설정 카테고리 - 모임 알림
          _buildSettingCategory(
            title: '모임 알림',
            icon: Icons.group,
            color: Colors.blue,
            children: [
              _buildSettingItem(
                title: '모임 정원 마감 알림',
                subtitle: '내가 주최한 모임의 정원이 마감되면 알림',
                settingKey: NotificationSettingKeys.meetupFull,
              ),
              _buildSettingItem(
                title: '모임 취소 알림',
                subtitle: '참여 신청한 모임이 취소되면 알림',
                settingKey: NotificationSettingKeys.meetupCancelled,
              ),
            ],
          ),

          // 설정 카테고리 - 게시글 알림
          _buildSettingCategory(
            title: '게시글 알림',
            icon: Icons.article,
            color: Colors.green,
            children: [
              _buildSettingItem(
                title: '댓글 알림',
                subtitle: '내 게시글에 댓글이 작성되면 알림',
                settingKey: NotificationSettingKeys.newComment,
              ),
              _buildSettingItem(
                title: '좋아요 알림',
                subtitle: '내 게시글에 좋아요가 추가되면 알림',
                settingKey: NotificationSettingKeys.newLike,
              ),
            ],
          ),

          // 추가 설정 - 알림 전체 ON/OFF
          _buildSettingCategory(
            title: '전체 설정',
            icon: Icons.settings,
            color: Colors.orange,
            children: [
              _buildSettingItem(
                title: '모든 알림',
                subtitle: '모든 알림 활성화/비활성화',
                settingKey: NotificationSettingKeys.allNotifications,
                isMainToggle: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCategory({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required String settingKey,
    bool isMainToggle = false,
  }) {
    // 모든 알림이 꺼져 있으면 다른 토글은 비활성화
    final bool allNotificationsOff = !(_settings[NotificationSettingKeys.allNotifications] ?? true);

    // 전체 알림 토글이 아니고, 전체 알림이 꺼져 있으면 비활성화
    final bool disabled = !isMainToggle && allNotificationsOff;

    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: disabled ? false : (_settings[settingKey] ?? true),
        onChanged: disabled
            ? null
            : (value) {
          _updateSetting(settingKey, value);
        },
        activeColor: isMainToggle ? Colors.orange : Colors.blue,
      ),
      enabled: !disabled,
    );
  }
}