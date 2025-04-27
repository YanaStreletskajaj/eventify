import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Экран событий')),
      bottomNavigationBar: BottomAppBar(
        height: 90,
        color: const Color(0xFF891F79),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/events'),
              child: Text(
                'События',
                style: TextStyle(
                  fontFamily: 'Unbounded',
                  fontSize: 15,
                  color: const Color(0xFF8EC6E0),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: Text(
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
              child: Text(
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
