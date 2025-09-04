class FirebaseResponseModel {
  final bool success;
  final String message;
  final FirebaseResponse firebaseResponse;

  FirebaseResponseModel({
    required this.success,
    required this.message,
    required this.firebaseResponse,
  });

  factory FirebaseResponseModel.fromJson(Map<String, dynamic> json) {
    return FirebaseResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      firebaseResponse: FirebaseResponse.fromJson(json['firebase_response']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'firebase_response': firebaseResponse.toJson(),
    };
  }
}

class FirebaseResponse {
  final String name;

  FirebaseResponse({required this.name});

  factory FirebaseResponse.fromJson(Map<String, dynamic> json) {
    return FirebaseResponse(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
