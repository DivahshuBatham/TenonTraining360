class CreateVirtualCourseResponse {
  final int status;
  final String message;
  final List<Course> data;

  CreateVirtualCourseResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CreateVirtualCourseResponse.fromJson(Map<String, dynamic> json) {
    return CreateVirtualCourseResponse(
      status: json['status'],
      message: json['message'],
      data: List<Course>.from(json['data'].map((x) => Course.fromJson(x))),
    );
  }
}

class Course {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? courseName;
  final String videoUrl;

  Course({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.courseName,
    required this.videoUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      courseName: json['course_name'],
      videoUrl: json['video_url'],
    );
  }
}
