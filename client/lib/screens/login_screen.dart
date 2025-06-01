import 'package:flutter/material.dart';
import 'package:events/services/api_service.dart';
import 'package:events/screens/home_screen.dart';
import 'package:events/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiService();

  void _handleLogin() async {
    final success = await _api.login(
      _phoneController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CalendarPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный номер или пароль')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Image.asset(
              'assets/images/circle_left.png', // Ваш путь к изображению
              width: 244,
              height: 197,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/circle_right.png',
              width: 244,
              height: 197,
              fit: BoxFit.contain,
            ),
          ),
      
      
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Вход", style: TextStyle(fontSize: 28, fontFamily: 'Unbounded')),
                const SizedBox(height: 30),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Номер телефона'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _handleLogin,
                    child: const Text('Далее', style: TextStyle(color: Colors.purple, fontFamily: 'Unbounded', fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text('Войти как новый пользователь', style: TextStyle(color: Colors.purple, fontFamily: 'Unbounded', fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}