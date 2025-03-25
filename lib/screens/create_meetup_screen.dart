import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meetup.dart';
import '../constants/app_constants.dart';
import '../services/meetup_service.dart';
import '../providers/auth_provider.dart';


// 모임 생성화면
// 모임 정보 입력 및 저장

class CreateMeetupScreen extends StatefulWidget {
  final int initialDayIndex;
  final Function(int, Meetup) onCreateMeetup;

  const CreateMeetupScreen({
    super.key,
    required this.initialDayIndex,
    required this.onCreateMeetup,
  });

  @override
  State<CreateMeetupScreen> createState() => _CreateMeetupScreenState();
}

class _CreateMeetupScreenState extends State<CreateMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedTime; // null로 시작하여 현재 시간 이후로 설정되도록 함
  int _maxParticipants = 3; // 기본값을 3으로 설정
  late int _selectedDayIndex;
  final _meetupService = MeetupService();
  final List<String> _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
  bool _isSubmitting = false;

  // 최대 인원 선택 목록
  final List<int> _participantOptions = [3, 4];

  // 30분 간격 시간 옵션 저장 리스트
  List<String> _timeOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = widget.initialDayIndex;
    // 선택된 날짜에 맞는 시간 옵션 생성 - initState에서 한 번 호출
    _updateTimeOptions();

    // 디버깅 출력 추가
    print('초기 시간 옵션: $_timeOptions');
    print('초기 선택된 시간: $_selectedTime');
  }

  // 선택된 날짜에 맞는 시간 옵션 업데이트
  void _updateTimeOptions() {
    // 현재 시간 가져오기
    final now = DateTime.now();
    // 선택된 날짜 가져오기
    final selectedDate = _meetupService.getWeekDates()[_selectedDayIndex];

    // 선택한 날짜가 오늘인지 확인
    final bool isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    // 새로운 시간 옵션 리스트
    List<String> newOptions = [];

    // 오늘이면 현재 시간 이후만, 아니면 하루 전체 시간
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        // 시간 문자열 생성
        final String hourStr = hour.toString().padLeft(2, '0');
        final String minuteStr = minute.toString().padLeft(2, '0');
        final String timeString = '$hourStr:$minuteStr';

        // 오늘이고 현재 시간 이후인 경우만 추가
        if (isToday) {
          // 현재 시간과 비교
          if (hour < now.hour || (hour == now.hour && minute <= now.minute)) {
            // 이미 지난 시간이면 추가하지 않음
            continue;
          }
        }

        // 유효한 시간 옵션 추가
        newOptions.add(timeString);
      }
    }

    // 디버깅 출력
    print('현재 시간: ${now.hour}:${now.minute}');
    print('선택된 날짜: ${selectedDate.day}일 (오늘? $isToday)');
    print('생성된 시간 옵션: $newOptions');

    // 상태 업데이트
    setState(() {
      _timeOptions = newOptions;

      // 옵션이 있으면 첫 번째를 선택, 없으면 null
      if (_timeOptions.isNotEmpty) {
        _selectedTime = _timeOptions.first;
      } else {
        _selectedTime = null;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 날짜 기준 일주일 날짜 계산 (오늘부터 6일 후까지)
    final List<DateTime> weekDates = _meetupService.getWeekDates();

    // 선택된 날짜
    final DateTime selectedDate = weekDates[_selectedDayIndex];
    // 요일 이름 가져오기 (월, 화, 수, ...)
    final String weekdayName = _weekdayNames[selectedDate.weekday - 1];
    final String dateStr = '${selectedDate.month}월 ${selectedDate.day}일 ($weekdayName)';

    // 사용자 닉네임 가져오기
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nickname = authProvider.userData?['nickname'] ?? AppConstants.DEFAULT_HOST;

    return AlertDialog(
      title: Text(AppConstants.CREATE_MEETUP),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주최자 정보
              Text(
                '주최자: $nickname',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // 날짜 선택 드롭다운
              DropdownButtonFormField<int>(
                value: _selectedDayIndex,
                decoration: InputDecoration(labelText: AppConstants.FORM_DAY),
                items: List.generate(
                  weekDates.length,
                      (index) {
                    final DateTime date = weekDates[index];
                    final String weekday = _weekdayNames[date.weekday - 1];
                    return DropdownMenuItem(
                      value: index,
                      child: Text('${date.month}월 ${date.day}일 ($weekday)'),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value != null && value != _selectedDayIndex) {
                    setState(() {
                      _selectedDayIndex = value;
                    });
                    // 날짜가 변경되면 시간 옵션 업데이트
                    _updateTimeOptions();
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 모임 제목
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: AppConstants.FORM_TITLE),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.FORM_TITLE_ERROR;
                  }
                  return null;
                },
              ),

              // 모임 설명
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: AppConstants.FORM_DESCRIPTION),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '모임 설명을 입력해주세요';
                  }
                  return null;
                },
              ),

              // 모임 장소
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: AppConstants.FORM_LOCATION),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '장소를 입력해주세요';
                  }
                  return null;
                },
              ),

              // 시간 선택 영역
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.FORM_TIME,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 시간 옵션이 없는 경우
                  if (_timeOptions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '오늘은 이미 지난 시간입니다. 다른 날짜를 선택해주세요.',
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                    )
                  // 시간 선택 드롭다운
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedTime,
                      isExpanded: true, // 드롭다운을 전체 너비로 확장
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _timeOptions.map((String time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTime = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '시간을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 최대 인원 선택 드롭다운
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.FORM_MAX_PARTICIPANTS,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _maxParticipants,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _participantOptions.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value명'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _maxParticipants = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () {
            Navigator.of(context).pop();
          },
          child: Text(AppConstants.CANCEL),
        ),
        ElevatedButton(
          onPressed: (_isSubmitting || _timeOptions.isEmpty || _selectedTime == null) ? null : () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _isSubmitting = true;
              });

              _formKey.currentState!.save();

              try {
                // Firebase에 모임 생성
                final success = await _meetupService.createMeetup(
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  location: _locationController.text.trim(),
                  time: _selectedTime!, // 선택된 시간 사용
                  maxParticipants: _maxParticipants,
                  date: selectedDate,
                );

                if (success) {
                  if (mounted) {
                    // 콜백은 호출하지 않고 창만 닫음 (Firebase에서 이미 데이터가 생성됨)
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('모임이 생성되었습니다!')),
                    );
                  }
                } else if (mounted) {
                  setState(() {
                    _isSubmitting = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모임 생성에 실패했습니다. 다시 시도해주세요.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isSubmitting = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('오류가 발생했습니다: $e')),
                  );
                }
              }
            }
          },
          child: _isSubmitting
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(AppConstants.CREATE),
        ),
      ],
    );
  }
}