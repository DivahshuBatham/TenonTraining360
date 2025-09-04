class VirtualTrainingByTrainerResponse {
  final bool status;
  final String message;
  final List<TrainingData> data;

  VirtualTrainingByTrainerResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VirtualTrainingByTrainerResponse.fromJson(Map<String, dynamic> json) {
    return VirtualTrainingByTrainerResponse(
      status: json['status'],
      message: json['message'],
      data: List<TrainingData>.from(
        json['data'].map((x) => TrainingData.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((x) => x.toJson()).toList(),
  };
}

class TrainingData {
  final int id;
  final int trainerId;
  final String courseName;
  final String date;
  final String time;
  final List<String> traineeName;
  final String createdAt;
  final String updatedAt;
  final String trainerName;
  final List<int> traineeId;
  final dynamic isJoined;
  final int courseId;
  final int totalAttendance;
  final int totalTrainees;
  final int siteId;
  final String siteName;
  final String status;
  final String? pdfUrl;
  final String? videoUrl;

  TrainingData({
    required this.id,
    required this.trainerId,
    required this.courseName,
    required this.date,
    required this.time,
    required this.traineeName,
    required this.createdAt,
    required this.updatedAt,
    required this.trainerName,
    required this.traineeId,
    this.isJoined,
    required this.courseId,
    required this.totalAttendance,
    required this.totalTrainees,
    required this.siteId,
    required this.siteName,
    required this.status,
    this.pdfUrl,
    this.videoUrl,
  });

  factory TrainingData.fromJson(Map<String, dynamic> json) {
    return TrainingData(
      id: json['id'],
      trainerId: json['trainer_id'],
      courseName: json['course_name'],
      date: json['date'],
      time: json['time'],
      traineeName: List<String>.from(json['trainee_name']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      trainerName: json['trainer_name'],
      traineeId: List<int>.from(json['trainee_id']),
      isJoined: json['is_joined'],
      courseId: json['course_id'],
      totalAttendance: json['total_attendance'],
      totalTrainees: json['total_trainees'],
      siteId: json['site_id'],
      siteName: json['site_name'],
      status: json['status'],
      pdfUrl: json['pdf_url'],
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainer_id': trainerId,
    'course_name': courseName,
    'date': date,
    'time': time,
    'trainee_name': traineeName,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'trainer_name': trainerName,
    'trainee_id': traineeId,
    'is_joined': isJoined,
    'course_id': courseId,
    'total_attendance': totalAttendance,
    'total_trainees': totalTrainees,
    'site_id': siteId,
    'site_name': siteName,
    'status': status,
    'pdf_url': pdfUrl,
    'video_url': videoUrl,
  };
}
