// lib/utils/error_handling_utils.dart
// 에러 처리와 관련된 유틸리티 함수 모아둔 파일
// 에러 메시지 표시, 데이터 로딩 실패 위젯, 데이터 없음 위젯 등을 제공
// 앱 전체에서 일관된 에러처리 목적



import 'package:flutter/material.dart';

class ErrorHandlingUtils {
  // 일반적인 에러 핸들링 메서드
  static void handleError(BuildContext context, dynamic error) {
    // 에러 로깅 (개발 중에만 출력)
    debugPrint('Error: $error');

    // 사용자에게 에러 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('오류가 발생했습니다: ${_getErrorMessage(error)}'),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // 에러 메시지 생성 메서드
  static String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return '알 수 없는 오류가 발생했습니다';
    }
  }

  // 데이터 로딩 실패 위젯
  static Widget buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  // 데이터 없음 위젯
  static Widget buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}