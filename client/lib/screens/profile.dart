import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _profile;

  final String baseUrl = 'http://31.207.76.8';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profile = _getProfile();
    });
  }

  Future<Map<String, dynamic>?> _getProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) throw Exception('Нет токена');

  final response = await http.get(
    Uri.parse('$baseUrl/users/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json; charset=utf-8', // Явно указываем кодировку
    },
  );

  print('Raw bytes: ${response.bodyBytes}'); // Для отладки

  if (response.statusCode == 200) {
    // Декодируем через bodyBytes с явным указанием кодировки
    final decodedBody = utf8.decode(response.bodyBytes);
    print('Decoded response: $decodedBody'); // Логируем результат
    return jsonDecode(decodedBody);
  } else {
    final errorBody = utf8.decode(response.bodyBytes); // Читаем ошибку в UTF-8
    throw Exception('Ошибка получения профиля: ${response.statusCode}. $errorBody');
  }
}
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          } else if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return _buildUserCard(snapshot.data!);
          }
          return _buildEmpty();
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildError(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Ошибка: $error', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadProfile, child: const Text('Повторить')),
      ],
    ),
  );

  Widget _buildEmpty() => const Center(
    child: Text(
      'Нет данных о пользователе',
      style: TextStyle(fontSize: 18, color: Colors.grey),
    ),
  );

  Widget _buildUserCard(Map<String, dynamic> user) => IntrinsicHeight(
    child: Card(
      elevation: 8,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            _buildUserInfoRow('Имя', user['first_name'] ?? ''),
            _buildUserInfoRow('Фамилия', user['last_name'] ?? ''),
            _buildUserInfoRow('Телефон', user['phone'] ?? ''),
          ],
        ),
      ),
    ),
  );

  Widget _buildCardHeader() => Row(
    children: [
      const Icon(Icons.person_outline, size: 30, color: Color(0xFF891F79)),
      const SizedBox(width: 10),
      Text(
        'Пользователь',
        style: TextStyle(
          fontFamily: 'Unbounded',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    ],
  );

  Widget _buildUserInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Unbounded',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'Unbounded', fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  Widget _buildBottomBar() => BottomAppBar(
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
                  color: Color(0xFF8EC6E0),
                ),
              ),
            ),
          ],
        ),
      );
}