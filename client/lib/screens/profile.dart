import 'package:events/models/user_model.dart';
import 'package:events/services/user_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<List<UserResponse>> _users;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _users = _userService.getUsers().catchError((error) {
        debugPrint('Error loading users: $error');
        throw error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add_users'),
            child: const Text('Добавить'),
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
            return _buildUserContent(snapshot.data!);
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
        ElevatedButton(onPressed: _loadUsers, child: const Text('Повторить')),
      ],
    ),
  );

  Widget _buildUserContent(List<UserResponse> users) {
    if (users.isEmpty) return _buildEmpty();
    final user = users.last;

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildUserCard(user),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/users'),
                  child: const Text('Все пользователи'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(UserResponse user) => Card(
    elevation: 8,
    margin: EdgeInsets.zero,
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
          _buildUserInfoRow('Имя', user.firstName),
          _buildUserInfoRow('Фамилия', user.lastName),
          _buildUserInfoRow('Телефон', user.phone),
        ],
      ),
    ),
  );

  Widget _buildCardHeader() => Row(
    children: [
      const Icon(Icons.person_outline, size: 30, color: Colors.blue),
      const SizedBox(width: 10),
      Text(
        'Пользователь',
        style: TextStyle(
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty() => const Center(
    child: Text(
      'Пользователи не найдены',
      style: TextStyle(fontSize: 18, color: Colors.grey),
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
