class VirtualCourseFilterById {
  final bool status;
  final String message;
  final List<CourseData> data;

  VirtualCourseFilterById({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VirtualCourseFilterById.fromJson(Map<String, dynamic> json) {
    return VirtualCourseFilterById(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<CourseData>.from(json['data'].map((x) => CourseData.fromJson(x)))
          : [],
    );
  }
}

class CourseData {
  final int id;
  final String courseName;
  final String trainingType;
  final String? pdfUrl;
  final String? videoUrl;
  final DateTime? createdAt;

  CourseData({
    required this.id,
    required this.courseName,
    required this.trainingType,
    this.pdfUrl,
    this.videoUrl,
    this.createdAt,
  });

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      id: json['id'] ?? 0,
      courseName: json['course_name'] ?? '',
      trainingType: json['training_type'] ?? '',
      pdfUrl: json['pdf_url'],
      videoUrl: json['video_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
