// lib/services/user_service.dart
import 'dart:convert';
import 'package:events/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String apiUrl = 'http://31.207.76.8/users/';

  Future<UserResponse> createUser(UserRequestCreate userRequest) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userRequest.toJson()),
    );

    if (response.statusCode == 201) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  Future<List<UserResponse>> getUsers() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);

      return data.map((user) => UserResponse.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }
}
