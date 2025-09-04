class TrainerResponse {
  final int id;
  final String? title;
  final String? video_url;
  final String? trainerName;
  final String? course_name;
  final String? status_type;
  final int? time;

  TrainerResponse({
  required this.id,
  this.title,
  this.video_url,
  this.trainerName,
  this.course_name,
  this.status_type,
  this.time
  });

  factory TrainerResponse.fromJson(Map<String, dynamic> json) {
  return TrainerResponse(
  id: json['id'],
  title: json['title'],
    video_url: json['video_url'],
  trainerName: json['trainer_name'],
    course_name: json['course_name'],
    status_type: json['status_type'],
    time: json['time']
  );
  }

  Map<String, dynamic> toJson() {
  return {
  'id': id,
  'title': title,
  'video_url': video_url,
  'trainer_name': trainerName,
    'course_name': course_name,
    'status_type': status_type,
    'time': time
  };
  }
}
