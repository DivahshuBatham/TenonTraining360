class CreatePhysicalCourseResponse {
  final int status;
  final String message;
  final List<PhysicalCourse> data;

  CreatePhysicalCourseResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CreatePhysicalCourseResponse.fromJson(Map<String, dynamic> json) {
    return CreatePhysicalCourseResponse(
      status: json['status'],
      message: json['message'],
      data: List<PhysicalCourse>.from(json['data'].map((x) => PhysicalCourse.fromJson(x))),
    );
  }
}

class PhysicalCourse {
  final int id;
  final String courseName;
  final DateTime createdAt;
  final DateTime updatedAt;

  PhysicalCourse({
    required this.id,
    required this.courseName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhysicalCourse.fromJson(Map<String, dynamic> json) {
    return PhysicalCourse(
      id: json['id'],
      courseName: json['course_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
