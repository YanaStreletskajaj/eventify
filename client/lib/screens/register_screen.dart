import 'package:flutter/material.dart';
import 'package:events/services/api_service.dart';
import 'package:events/screens/login_screen.dart';
import 'package:events/screens/home_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _api = ApiService();

  void _register() async {
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают')),
      );
      return;
    }

    final success = await _api.register(
      firstName: _firstName.text,
      lastName: _lastName.text,
      phone: _phone.text,
      password: _password.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CalendarPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка регистрации')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          children: [
            const Text("Регистрация", style: TextStyle(fontSize: 28, fontFamily: 'Unbounded')),
            const SizedBox(height: 20),
            TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Имя')),
            const SizedBox(height: 10),
            TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Фамилия')),
            const SizedBox(height: 10),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Номер')),
            const SizedBox(height: 10),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Пароль')),
            const SizedBox(height: 10),
            TextField(controller: _confirmPassword, obscureText: true, decoration: const InputDecoration(labelText: 'Повтор пароля')),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _register,
                child: const Text('Далее', style: TextStyle(color: Colors.purple, fontFamily: 'Unbounded', fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Войти в существующий аккаунт', style: TextStyle(color: Colors.purple, fontFamily: 'Unbounded', fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}