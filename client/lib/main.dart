import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/events.dart';
import 'screens/profile.dart';
import 'screens/create.dart';
import 'screens/user_screen.dart';
import 'screens/add_user_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/notification_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Unbounded'),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(fontFamily: 'Unbounded'),
        ),
      ),
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
      onGenerateRoute: _generateRoute,
      routes: {
        '/': (context) => const SplashScreen(),
        '/add_users': (context) => const AddUserScreen(),
        '/home': (context) => const CalendarPage(),
        '/events': (context) => const EventsPage(),
        '/profile': (context) => const ProfileScreen(),
        '/users': (context) => const UserScreen(),
        '/add_event': (context) => const CreateEventPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
Route<dynamic> _generateRoute(RouteSettings settings) {
  Widget page;

  switch (settings.name) {
    case '/':
      page = const SplashScreen();
      break;
    case '/home':
      page = const CalendarPage();
      break;
    case '/events':
      page = const EventsPage();
      break;
    case '/profile':
      page = const ProfileScreen();
      break;
    case '/users':
      page = const UserScreen();
      break;
    case '/add_users':
      page = const AddUserScreen();
      break;
    case '/add_event':
      page = const CreateEventPage();
      break;
    case '/login':
      page = const LoginScreen();
      break;
    case '/register':
      page = const RegisterScreen();
      break;
    default:
      page = const SplashScreen(); // fallback
  }

  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

