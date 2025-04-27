import 'package:events/models/user_model.dart';
import 'package:events/services/user_service.dart';
import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key}); // Добавлен ключ

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService _userService = UserService();
  late Future<List<UserResponse>> _users;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _users = _userService.getUsers()
        .catchError((error) { // Ловим ошибки на уровне Future
          debugPrint('Error loading users: $error');
          throw error;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'), // const для оптимизации
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add_users'),
            child: const Text('Пользователь'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers, // Добавлена кнопка обновления
          ),
        ],
      ),
      body: FutureBuilder<List<UserResponse>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          } else if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return _buildUserList(snapshot.data!);
          }
          return _buildEmpty();
        },
      ),
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildError(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: $error', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadUsers,
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _buildUserList(List<UserResponse> users) {
    if (users.isEmpty) return _buildEmpty();
    
    return RefreshIndicator( // Добавлен Pull-to-Refresh
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) => _buildUserItem(users[index]),
      ),
    );
  }

  Widget _buildUserItem(UserResponse user) => ListTile(
    title: Text('${user.firstName} ${user.lastName}'), // Интерполяция строк
    subtitle: Text(user.phone),
    dense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );

  Widget _buildEmpty() => const Center(
    child: Text('No users found', style: TextStyle(fontSize: 16)),
  );
  
}