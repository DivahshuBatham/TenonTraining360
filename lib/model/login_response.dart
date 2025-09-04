class LoginResponse {
  final String status;
  final String message;
  final UserData data;
  final String token;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
      'token': token,
    };
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String role;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
