import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/events.dart';
import 'screens/profile.dart';
import 'screens/create_event.dart';
import 'screens/user_screen.dart';
import 'screens/add_user_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations
            .delegate, // Provides Material widget localizations
        GlobalWidgetsLocalizations
            .delegate, // Defines text direction (e.g., RTL)
        GlobalCupertinoLocalizations
            .delegate, // For Cupertino widgets (optional)
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English (fallback)
        Locale('ru', 'RU'), // Russian
      ],
      // Optional: Set a default locale if needed
      locale: const Locale('ru', 'RU'),
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/add_users': (context) => const AddUserScreen(),
        '/home': (context) => const CalendarPage(),
        '/events': (context) => const EventsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/users': (context) => const UserScreen(),
        '/add_event': (context) => const CreateEventPage(),
      },
    );
  }
}
