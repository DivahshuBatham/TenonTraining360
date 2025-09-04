class CourseResponse {
  final bool status;
  final String message;
  final List<Course> data;

  CourseResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    return CourseResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((item) => Course.fromJson(item))
          .toList(),
    );
  }
}

class Course {
  final int id;
  final String courseName;
  final String trainingType;
  final String pdfUrl;
  final String createdAt;
  final String videoUrl;

  Course({
    required this.id,
    required this.courseName,
    required this.trainingType,
    required this.pdfUrl,
    required this.createdAt,
    required this.videoUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      courseName: json['course_name'] ?? '',
      trainingType: json['training_type'] ?? '',
      pdfUrl: json['pdf_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      videoUrl: json['video_url'] ?? '',
    );
  }
}
