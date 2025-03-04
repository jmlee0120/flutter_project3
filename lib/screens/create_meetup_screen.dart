import 'package:flutter/material.dart';
import '../models/meetup.dart';
import '../constants/app_constants.dart';
import '../services/meetup_service.dart';

class CreateMeetupScreen extends StatefulWidget {
  final int initialDayIndex;
  final Function(int, Meetup) onCreateMeetup;

  const CreateMeetupScreen({
    Key? key,
    required this.initialDayIndex,
    required this.onCreateMeetup,
  }) : super(key: key);

  @override
  State<CreateMeetupScreen> createState() => _CreateMeetupScreenState();
}

class _CreateMeetupScreenState extends State<CreateMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _location = '';
  String _time = '';
  int _maxParticipants = AppConstants.DEFAULT_MAX_PARTICIPANTS;
  late int _selectedDayIndex;
  final _meetupService = MeetupService();

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = widget.initialDayIndex;
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 요일의 날짜 계산
    final DateTime dayDate = _meetupService.getDayDate(_selectedDayIndex);
    final String dateStr = '${dayDate.month}월 ${dayDate.day}일 (${AppConstants.DAYS[_selectedDayIndex]})';

    return AlertDialog(
      title: Text(AppConstants.CREATE_MEETUP),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedDayIndex,
                decoration: InputDecoration(labelText: AppConstants.FORM_DAY),
                items: List.generate(
                  AppConstants.DAYS.length,
                      (index) {
                    // 각 요일에 해당하는 날짜 계산
                    final DateTime date = _meetupService.getDayDate(index);
                    return DropdownMenuItem(
                      value: index,
                      child: Text('${date.month}월 ${date.day}일 (${AppConstants.DAYS[index]})'),
                    );
                  },
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedDayIndex = value!;
                  });
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
              TextFormField(
                decoration: InputDecoration(labelText: AppConstants.FORM_TITLE),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.FORM_TITLE_ERROR;
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: AppConstants.FORM_DESCRIPTION),
                maxLines: 2,
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: AppConstants.FORM_LOCATION),
                onSaved: (value) {
                  _location = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: AppConstants.FORM_TIME),
                onSaved: (value) {
                  _time = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: AppConstants.FORM_MAX_PARTICIPANTS),
                keyboardType: TextInputType.number,
                initialValue: '${AppConstants.DEFAULT_MAX_PARTICIPANTS}',
                onSaved: (value) {
                  _maxParticipants = int.tryParse(value ?? '${AppConstants.DEFAULT_MAX_PARTICIPANTS}') ?? AppConstants.DEFAULT_MAX_PARTICIPANTS;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppConstants.CANCEL),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // 선택된 요일의 날짜
              final DateTime meetupDate = _meetupService.getDayDate(_selectedDayIndex);

              final newId = DateTime.now().millisecondsSinceEpoch;
              final newMeetup = Meetup(
                id: newId,
                title: _title,
                description: _description,
                location: _location,
                time: _time,
                maxParticipants: _maxParticipants,
                currentParticipants: 1, // 호스트 포함
                host: AppConstants.DEFAULT_HOST,
                imageUrl: AppConstants.DEFAULT_IMAGE_URL,
                date: meetupDate, // 날짜 추가
              );
              widget.onCreateMeetup(_selectedDayIndex, newMeetup);
              Navigator.of(context).pop();
            }
          },
          child: Text(AppConstants.CREATE),
        ),
      ],
    );
  }
}