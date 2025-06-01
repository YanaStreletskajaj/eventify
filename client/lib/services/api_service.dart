import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:events/models/user_model.dart';
import 'package:events/models/event_model.dart';

class ApiService {
  final String baseUrl = 'http://31.207.76.8';

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      // опционально логинимся сразу
      return await login(phone, password);
    } else {
      print('Ошибка регистрации: ${response.statusCode} / ${response.body}');
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': phone, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      return true;
    } else {
      return false;
    }
  }

  Future<UserResponse> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json; charset=utf-8',
      },
    );

    print("Response UTF8: ${utf8.decode(response.bodyBytes)}");

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonData = json.decode(decodedBody);
      return UserResponse.fromJson(jsonData);
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      throw Exception('Failed to load user: $errorBody');
    }
  }

  Future<bool> createEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/events/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': event.id,
        'name': event.title,
        'location': event.location,
        'start_time': event.startDate.toIso8601String(),
        'end_time': event.endDate.toIso8601String(),
        'repeat_interval': event.repeat,
        'reminder_interval': event.reminder,
        'notes': event.notes,
      }),
    );

    print('--- СОЗДАНИЕ СОБЫТИЯ ---');
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    print(
      'Request body: ${jsonEncode({'id': event.id, 'name': event.title, 'location': event.location, 'start_time': event.startDate.toIso8601String(), 'end_time': event.endDate.toIso8601String(), 'repeat_interval': event.repeat, 'reminder_interval': event.reminder, 'notes': event.notes})}',
    );

    return response.statusCode == 201;
  }

  Future<List<Event>> fetchEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/events/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('--- СОБЫТИT ---');
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map(
            (json) => Event(
              id: json['id'],
              title: json['name'],
              startDate: DateTime.parse(json['start_time']),
              endDate: DateTime.parse(json['end_time']),
              location: json['location'],
              notes: json['notes'],
              repeat: json['repeat_interval'],
              reminder: json['reminder_interval'],
            ),
          )
          .toList();
    } else {
      throw Exception('Ошибка при загрузке событий: ${response.body}');
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/events/$eventId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  Future<Event> fetchEventById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/events/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Event(
        id: json['id'],
        title: json['name'],
        startDate: DateTime.parse(json['start_time']),
        endDate: DateTime.parse(json['end_time']),
        location: json['location'],
        notes: json['notes'],
        repeat: json['repeat_interval'],
        reminder: json['reminder_interval'],
      );
    } else {
      throw Exception('Событие не найдено');
    }
  }

  Future<bool> joinEventById(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/events/$eventId/join'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
