import 'package:events/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:events/models/event_model.dart';
import 'package:events/services/notification_service.dart';

class CreateEventPage extends StatefulWidget {
  final Event? event;
  const CreateEventPage({super.key, this.event});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  String _repeatValue = 'Никогда';
  String _reminderValue = 'Никогда';

  final List<String> _repeatOptions = [
    'Никогда',
    'Каждый день',
    'Каждую неделю',
    'Каждый месяц',
    'Каждый год'
  ];

  final List<String> _reminderOptions = [
    'Никогда',
    'За неделю',
    'За 3 дня',
    'За 1 день',
    'За 1 час'
  ];

  final Color primaryColor = const Color(0xFF891F79);
  final Color focusColor = const Color(0xFF2E3996);

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartDate ? _startDate : _endDate),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStartDate) {
            _startDate = newDateTime;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text,
        notes: _notesController.text,
        repeat: _repeatValue,
        reminder: _reminderValue,
      );

      final success = await ApiService().createEvent(newEvent);

      if (success) {
        final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
        Duration? reminderOffset;
        switch (_reminderValue) {
          case 'За неделю':
            reminderOffset = const Duration(days: 7);
            break;
          case 'За 3 дня':
            reminderOffset = const Duration(days: 3);
            break;
          case 'За 1 день':
            reminderOffset = const Duration(days: 1);
            break;
          case 'За 1 час':
            reminderOffset = const Duration(hours: 1);
            break;
          default:
            reminderOffset = null;
        }

        if (reminderOffset != null) {
          final notificationTime = _startDate.subtract(reminderOffset);

          // ⬇️ Вставляем сюда
          

          if (notificationTime.isAfter(DateTime.now())) {
            await NotificationService.scheduleNotification(
              id: id,
              title: 'Напоминание: ${_titleController.text}',
              body: 'Событие начнётся в ${DateFormat.Hm().format(_startDate)}',
              scheduledTime: notificationTime,
            );
          }
        } // можно также вернуть null, если не нужно использовать
      }
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Unbounded'),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: focusColor, width: 2.0),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text(
              'Создать',
              style: TextStyle(
                fontFamily: 'Unbounded',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF891F79),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Название'),
                style: const TextStyle(fontFamily: 'Unbounded'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название события';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Геопозиция (ссылка)'),
                style: const TextStyle(fontFamily: 'Unbounded'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDateTime(context, true),
                      child: InputDecorator(
                        decoration: _inputDecoration('Начало'),
                        child: Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(_startDate),
                          style: const TextStyle(fontFamily: 'Unbounded'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDateTime(context, false),
                      child: InputDecorator(
                        decoration: _inputDecoration('Конец'),
                        child: Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(_endDate),
                          style: const TextStyle(fontFamily: 'Unbounded'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _repeatValue,
                decoration: _inputDecoration('Повтор'),
                iconEnabledColor: primaryColor,
                style: const TextStyle(fontFamily: 'Unbounded', color: Colors.black),
                items: _repeatOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontFamily: 'Unbounded')),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _repeatValue = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _reminderValue,
                decoration: _inputDecoration('Напоминание'),
                iconEnabledColor: primaryColor,
                style: const TextStyle(fontFamily: 'Unbounded', color: Colors.black),
                items: _reminderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontFamily: 'Unbounded')),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _reminderValue = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDecoration('Заметки').copyWith(alignLabelWithHint: true),
                style: const TextStyle(fontFamily: 'Unbounded'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

