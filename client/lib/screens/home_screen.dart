import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:events/models/event_model.dart';
import 'package:events/screens/event_details.dart';
import 'package:events/services/api_service.dart';
import 'package:events/screens/create.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final eventsFromServer = await ApiService().fetchEvents();
      setState(() {
        _events = eventsFromServer;
      });
    } catch (e) {
      print('Ошибка загрузки: $e');
      // optionally show a Snackbar or error UI
    }
    print('--------События загружены------');
  }
  bool _eventOccursOnDate(Event event, DateTime date) {
    final start = event.startDate;
    final repeat = event.repeat;

    final startDateOnly = DateTime(start.year, start.month, start.day);
    final currentDateOnly = DateTime(date.year, date.month, date.day);

    if (repeat == 'Никогда') {
      return isSameDay(start, date);
    }

    switch (repeat) {
      case 'Каждый день':
        return !currentDateOnly.isBefore(startDateOnly);

      case 'Каждую неделю':
        return currentDateOnly.weekday == startDateOnly.weekday &&
              !currentDateOnly.isBefore(startDateOnly);

      case 'Каждый месяц':
        return currentDateOnly.day == startDateOnly.day &&
              !currentDateOnly.isBefore(startDateOnly);

      case 'Каждый год':
        return currentDateOnly.day == startDateOnly.day &&
              currentDateOnly.month == startDateOnly.month &&
              !currentDateOnly.isBefore(startDateOnly);

      default:
        return isSameDay(start, date);
    }
  }

  Widget _buildEventsList() {
    final currentDate = _selectedDay ?? _focusedDay;
    final dailyEvents =
        _events
            .where((event) => _eventOccursOnDate(event, currentDate))
            .toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: dailyEvents.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final event = dailyEvents[index];
        return InkWell(
          onTap: () => _showEventDetails(context, event),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    DateFormat.Hm().format(event.startDate),
                    style: TextStyle(
                      fontFamily: 'Unbounded',
                      color: Color(0xFF891F79),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(fontFamily: 'Unbounded'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEventDetails(BuildContext context, Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EventDetailsPage(
              event: event,
              onUpdate: (updatedEvent) {
                setState(() {
                  final index = _events.indexOf(event);
                  _events[index] = updatedEvent;
                });
              },
            ),
      ),
    );
    await _loadEvents();

    if (result != null && result is Event) {
      setState(() {
        final index = _events.indexOf(event);
        _events[index] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 4.0),
            child: Text(
              _getMonthName(_focusedDay),
              style: const TextStyle(
                fontFamily: 'Unbounded',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF891F79),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek:
                  StartingDayOfWeek.monday, // Начало недели с понедельника
              locale: 'ru_RU', // Локализация на русский
              headerVisible: false,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: const TextStyle(
                  fontFamily: 'Unbounded',
                  color: Colors.black,
                ),
                weekendStyle: const TextStyle(
                  fontFamily: 'Unbounded',
                  color: Colors.red,
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(
                  fontFamily: 'Unbounded',
                  color: Colors.black,
                ),
                weekendTextStyle: const TextStyle(
                  fontFamily: 'Unbounded',
                  color: Color.fromARGB(255, 77, 76, 76),
                ),
                todayTextStyle: const TextStyle(
                  fontFamily: 'Unbounded',
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFFE7D3E4),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  fontFamily: 'Unbounded',
                  fontSize: 14,
                  color: Colors.white,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF891F79),
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              daysOfWeekHeight: 30,
              rowHeight: 50,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged:
                  (focusedDay) => setState(() => _focusedDay = focusedDay),
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) => Container(),
                dowBuilder: (context, day) {
                  final russianDays = [
                    'Пн',
                    'Вт',
                    'Ср',
                    'Чт',
                    'Пт',
                    'Сб',
                    'Вс',
                  ];
                  return Center(
                    child: Text(
                      russianDays[day.weekday - 1],
                      style: const TextStyle(
                        fontFamily: 'Unbounded',
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _buildDateControlBar(context),
          Expanded(child: _buildEventsList()),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        height: 90,
        color: const Color(0xFF891F79),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/events'),
              child: const Text(
                'События',
                style: TextStyle(
                  fontFamily: 'Unbounded',
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text(
                'Календарь',
                style: TextStyle(
                  fontFamily: 'Unbounded',
                  fontSize: 15,
                  color: Color(0xFF8EC6E0),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text(
                'Профиль',
                style: TextStyle(
                  fontFamily: 'Unbounded',
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateControlBar(BuildContext context) {
    final selectedDate = _selectedDay ?? _focusedDay;
    return Container(
      // Убрали вертикальные отступы, оставили только горизонтальные
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat("EEEE - d MMM y", 'ru_RU').format(selectedDate),
            style: const TextStyle(
              fontFamily: 'Unbounded',
              fontSize: 14,
              color: Color(0xFF891F79),
            ),
          ),
          // Заменили TextButton.icon на IconButton
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF8EC6E0),
              size: 28,
            ),
            onPressed: () async {
              // Добавляем async
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventPage(),
                ),
              ); // Ожидаем результат

              await _loadEvents();
              if (result != null && result is Event) {
                // Проверяем тип
                
                setState(() {
                  _selectedDay = result.startDate;
                  _focusedDay = result.startDate;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const List<String> monthNames = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }
}
