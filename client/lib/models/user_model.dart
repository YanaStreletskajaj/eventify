class UserRequestCreate {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;

  UserRequestCreate({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'password': password,
    };
  }
}

class UserResponse {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String createdAt;
  final String updatedAt;

  UserResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
