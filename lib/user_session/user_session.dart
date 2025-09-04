class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String id = '';
  String name = '';
  String email = '';
  String role = '';
  String token = '';
}
