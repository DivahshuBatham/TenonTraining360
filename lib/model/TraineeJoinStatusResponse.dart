class TraineeJoinStatusResponse {
  final int status;
  final String message;
  final String trainingId;
  final String trainingType;
  final String courseName;
  final int trainerId;
  final List<Trainee> trainees;

  TraineeJoinStatusResponse({
    required this.status,
    required this.message,
    required this.trainingId,
    required this.trainingType,
    required this.courseName,
    required this.trainerId,
    required this.trainees,
  });

  factory TraineeJoinStatusResponse.fromJson(Map<String, dynamic> json) {
    return TraineeJoinStatusResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      trainingId: json['training_id']?.toString() ?? '',
      trainingType: json['training_type'] ?? '',
      courseName: json['course_name'] ?? '',
      trainerId: json['trainer_id'] ?? 0,
      trainees: (json['trainees'] as List<dynamic>?)
          ?.map((e) => Trainee.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'training_id': trainingId,
      'training_type': trainingType,
      'course_name': courseName,
      'trainer_id': trainerId,
      'trainees': trainees.map((e) => e.toJson()).toList(),
    };
  }
}

class Trainee {
  final int traineeId;
  final String traineeName;
  bool isJoined;// mutable so UI can update
  String? joinedAt; // nullable
  bool isAssessment;
  bool isFeedback;
  bool isExit;

  Trainee({
    required this.traineeId,
    required this.traineeName,
    required this.isJoined,
    this.joinedAt,
    required this.isAssessment,
    required this.isFeedback,
    required this.isExit
  });

  factory Trainee.fromJson(Map<String, dynamic> json) {
    return Trainee(
      traineeId: json['trainee_id'] ?? 0,
      traineeName: json['trainee_name'] ?? '',
      isJoined: json['is_joined'] ?? false,
      isAssessment: json['is_assessment'] ?? false,
      isFeedback: json['is_feedback'] ?? false,
      isExit: json['is_exit'] ?? false,
      joinedAt: json['joined_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainee_id': traineeId,
      'trainee_name': traineeName,
      'is_joined': isJoined,
      'joined_at': joinedAt,
      'is_assessment': isAssessment,
      'is_feedback': isFeedback,
      'is_exit': isExit,
    };
  }
}


