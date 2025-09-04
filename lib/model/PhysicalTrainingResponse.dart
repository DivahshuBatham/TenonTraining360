class PhysicalTrainingResponse {
  final int status;
  final String message;
  final List<PhysicalTrainingData> data;

  PhysicalTrainingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PhysicalTrainingResponse.fromJson(Map<String, dynamic> json) {
    return PhysicalTrainingResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((item) => PhysicalTrainingData.fromJson(item))
          .toList(),
    );
  }
}

class PhysicalTrainingData {
  final int trainingId;
  final int trainerId;
  final String trainerName;
  final String courseName;
  final String date;
  final String time;
  final int siteId;
  final int totalTrainees;
  final String siteName;
  final int totalAttendance;
  final String trainerStatus;
  final List<Trainee> trainees;

  PhysicalTrainingData({
    required this.trainingId,
    required this.trainerId,
    required this.trainerName,
    required this.courseName,
    required this.date,
    required this.time,
    required this.totalAttendance,
    required this.trainerStatus,
    required this.siteId,
    required this.totalTrainees,
    required this.siteName,
    required this.trainees,
  });

  factory PhysicalTrainingData.fromJson(Map<String, dynamic> json) {
    return PhysicalTrainingData(
      trainingId: json['training_id'],
      trainerId: json['trainer_id'],
      trainerName: json['trainer_name'],
      courseName: json['course_name'],
      date: json['date'],
      time: json['time'],
      siteId: json['site_id'],
      siteName: json['site_name'],
      totalTrainees: json['total_trainees'],
      trainerStatus: json['status'],
      totalAttendance: json['total_attendance'],
      trainees: (json['trainee_name'] as List<dynamic>)
          .map((item) => Trainee.fromJson(item))
          .toList(),
    );
  }
}

class Trainee {
  final int traineeId;
  final String traineeName;

  Trainee({
    required this.traineeId,
    required this.traineeName,
  });

  factory Trainee.fromJson(Map<String, dynamic> json) {
    return Trainee(
      traineeId: json['trainee_id'],
      traineeName: json['trainee_name'],
    );
  }
}
