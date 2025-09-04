class PhysicalTrainingByTrainerResponse {
  final bool status;
  final String message;
  final String type;
  final List<PhysicalTrainingByTrainer> data;

  PhysicalTrainingByTrainerResponse({
    required this.status,
    required this.message,
    required this.type,
    required this.data,
  });

  factory PhysicalTrainingByTrainerResponse.fromJson(Map<String, dynamic> json) {
    return PhysicalTrainingByTrainerResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      data: List<PhysicalTrainingByTrainer>.from(
        (json['data'] ?? []).map((item) => PhysicalTrainingByTrainer.fromJson(item)),
      ),
    );
  }
}

class PhysicalTrainingByTrainer {
  final int id;
  final String trainerName;
  final String courseName;
  final String date;
  final String time;
  final String createdAt;
  final String updatedAt;
  final List<int> traineeId;
  final List<String> traineeName;
  final int trainerId;
  final int totalTrainees;
  final int totalAttendance;
  final int? notJoined;
  final List<int> notJoinedTraineeIds;
  final List<String> notJoinedTraineeNames;
  final int siteId;
  final String siteName;
  final String status;
  final String pdfUrl;
  final double? averageRating;

  PhysicalTrainingByTrainer({
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
    required this.totalTrainees,
    required this.totalAttendance,
    this.notJoined,
    required this.notJoinedTraineeIds,
    required this.notJoinedTraineeNames,
    required this.siteId,
    required this.siteName,
    required this.status,
    required this.pdfUrl,
    this.averageRating,
  });

  factory PhysicalTrainingByTrainer.fromJson(Map<String, dynamic> json) {
    return PhysicalTrainingByTrainer(
      id: json['id'] ?? 0,
      trainerName: json['trainer_name'] ?? '',
      courseName: json['course_name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      traineeId: List<int>.from(json['trainee_id'] ?? []),
      traineeName: List<String>.from(json['trainee_name'] ?? []),
      trainerId: json['trainer_id'] ?? 0,
      totalTrainees: json['total_trainees'] ?? 0,
      totalAttendance: json['total_attendance'] ?? 0,
      notJoined: json['not_joined'],
      notJoinedTraineeIds: List<int>.from(json['not_joined_trainee_ids'] ?? []),
      notJoinedTraineeNames: List<String>.from(json['not_joined_trainee_names'] ?? []),
      siteId: json['site_id'] ?? 0,
      siteName: json['site_name'] ?? '',
      status: json['status'] ?? '',
      pdfUrl: json['pdf_url'] ?? '',
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
    );
  }
}
