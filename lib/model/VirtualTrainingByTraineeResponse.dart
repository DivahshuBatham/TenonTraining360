class VirtualTrainingByTraineeResponse {
  final bool status;
  final String message;
  final List<VirtualTrainingData> data;

  VirtualTrainingByTraineeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VirtualTrainingByTraineeResponse.fromJson(Map<String, dynamic> json) {
    return VirtualTrainingByTraineeResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((e) => VirtualTrainingData.fromJson(e))
          .toList(),
    );
  }
}

class VirtualTrainingData {
  final int id;
  final String courseName;
  final int courseId;
  final String date;
  final String time;
  final int trainerId;
  final String trainerName;
  final int traineeId;
  final String traineeName;
  final String? videoUrl;
  final String? pdfUrl;
  final String createdAt;
  final String updatedAt;
  final int site_id;
  final int totalTrainees;
  final String siteName;
  final String status;
  final int totalAttendance;

  VirtualTrainingData({
    required this.id,
    required this.courseName,
    required this.courseId,
    required this.date,
    required this.time,
    required this.trainerId,
    required this.trainerName,
    required this.traineeId,
    required this.traineeName,
    required this.videoUrl,
    required this.pdfUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.totalTrainees,
    required this.site_id,
    required this.siteName,
    required this.status,
    required this.totalAttendance
  });

  factory VirtualTrainingData.fromJson(Map<String, dynamic> json) {
    return VirtualTrainingData(
      id: json['id'],
      courseName: json['course_name'],
      courseId: json['course_id'],
      date: json['date'],
      time: json['time'],
      trainerId: json['trainer_id'],
      trainerName: json['trainer_name'],
      traineeId: json['trainee_id'],
      traineeName:(json['trainee_name']),
      videoUrl: json['video_url'],
      pdfUrl: json['pdf_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      site_id: json['site_id'],
      siteName: json['site_name'],
      status: json['status'],
      totalTrainees: json['total_trainees'],
      totalAttendance: json['total_attendance'],
    );

  }
}
