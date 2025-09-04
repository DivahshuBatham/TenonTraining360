class PhysicalTrainingByTraineeResponse {
  final bool status;
  final String message;
  final String type;
  final List<PhysicalTrainingByTraineeData> data;

  PhysicalTrainingByTraineeResponse({
    required this.status,
    required this.message,
    required this.type,
    required this.data,
  });

  factory PhysicalTrainingByTraineeResponse.fromJson(Map<String, dynamic> json) {
    return PhysicalTrainingByTraineeResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PhysicalTrainingByTraineeData.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class PhysicalTrainingByTraineeData {
  final int id;
  final String trainerName;
  final String courseName;
  final String date;
  final String time;
  final String createdAt;
  final String updatedAt;
  final int traineeId;
  final String traineeName;
  final int trainerId;
  final String? isJoined;
  final int totalTrainees;
  final int totalAttendance;
  final int siteId;
  final String siteName;
  final String status;
  final String pdfUrl;
  final int averageRating;

  PhysicalTrainingByTraineeData({
    required this.id,
    required this.trainerName,
    required this.courseName,
    required this.date,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
    required this.traineeId,
    required this.traineeName,
    required this.trainerId,
    this.isJoined,
    required this.totalTrainees,
    required this.totalAttendance,
    required this.siteId,
    required this.siteName,
    required this.status,
    required this.pdfUrl,
    required this.averageRating
  });

  factory PhysicalTrainingByTraineeData.fromJson(Map<String, dynamic> json) {
    return PhysicalTrainingByTraineeData(
      id: json['id'] ?? 0,
      trainerName: json['trainer_name'] ?? '',
      courseName: json['course_name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      traineeId: json['trainee_id'] ?? 0,
      traineeName: json['trainee_name'] ?? '',
      trainerId: json['trainer_id'] ?? 0,
      isJoined: json['is_joined'],
      totalTrainees: json['total_trainees'] ?? 0,
      totalAttendance: json['total_attendance'] ?? 0,
      siteId: json['site_id'] ?? 0,
      siteName: json['site_name'] ?? '',
      status: json['status'] ?? '',
      pdfUrl: json['pdf_url'] ?? '',
      averageRating: json['average_rating'] ?? 0,
    );
  }
}
