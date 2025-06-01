import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:events/models/event_model.dart';
import 'package:events/services/api_service.dart';
import 'package:events/screens/event_details.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime _focusedDay = DateTime.now();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final eventsFromServer = await ApiService().fetchEvents();
      final now = _focusedDay;

      final todayEvents =
          eventsFromServer.where((event) {
            final start = event.startDate;
            return start.year == now.year &&
                start.month == now.month &&
                start.day == now.day;
          }).toList();

      setState(() {
        _events = todayEvents;
      });
    } catch (e) {
      print('Ошибка загрузки: $e');
      // optionally show a Snackbar or error UI
    }
    print('--------События загружены------');
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
  String? _extractEventIdFromLink(String link) {
    try {
      final uri = Uri.parse(link);
      final segments = uri.pathSegments;
      if (segments.length >= 2 && segments.first == 'event') {
        return segments[1];
      }
    } catch (_) {}
    return null;
  }

  void _showJoinDialog() {
    final _linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Присоединиться', style: TextStyle(fontFamily: 'Unbounded')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Вставьте ссылку на событие'),
              const SizedBox(height: 8),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'https://events.app/event/123',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final link = _linkController.text.trim();
                final eventId = _extractEventIdFromLink(link);

                if (eventId != null) {
                  try {
                    // 1. Загружаем событие с сервера
                    final event = await ApiService().fetchEventById(eventId);

                    // 2. Пробуем присоединиться (добавить к текущему пользователю)
                    final success = await ApiService().joinEventById(eventId);

                    if (!mounted) return;
                    Navigator.pop(ctx);

                    if (success) {
                      setState(() {
                        final alreadyExists = _events.any((e) => e.id == event.id);
                        if (!alreadyExists) {
                          _events.add(event);
                        }
                      });

                      // 3. Открываем экран деталей события
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsPage(
                            event: event,
                            onUpdate: (updatedEvent) {
                              setState(() {
                                final index = _events.indexWhere((e) => e.id == updatedEvent.id);
                                if (index != -1) {
                                  _events[index] = updatedEvent;
                                }
                              });
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Не удалось присоединиться к событию')),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Событие не найдено')),
                    );
                  }
                } else {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Неверная ссылка')),
                  );
                }
              },
              child: const Text('ОК', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMMM', 'ru_RU').format(DateTime.now());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              'Сегодня, $today',
              style: const TextStyle(fontSize: 30, fontFamily: 'Unbounded', color: Colors.black,),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:_events.isEmpty ? const Center(child: Text('Нет событий на сегодня')): 
              ListView.builder(
                itemCount: _events.length,
                itemBuilder: (ctx, i) {
                  final event = _events[i];
                  return GestureDetector(
                    onTap: () => _showEventDetails(context, event),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7D3E4),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Unbounded',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(event.startDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Unbounded',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox (height: 16),
            TextButton(
              onPressed: _showJoinDialog,
              child: const Text(
                'Присоединиться',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF891F79),
                  fontFamily: 'Unbounded',
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ], 
        ),
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
                  color: Color(0xFF8EC6E0),
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
                  color: Colors.white,
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
}
