class TrainingData {
  final int trainingId;
  final int trainerId;
  final String trainerName;
  final String courseName;
  final String date;
  final String time;
  final List<String> traineeName;
  final List<int> traineeId;

  TrainingData({
    required this.trainingId,
    required this.trainerId,
    required this.trainerName,
    required this.courseName,
    required this.date,
    required this.time,
    required this.traineeName,
    required this.traineeId,
  });

  factory TrainingData.fromJson(Map<String, dynamic> json) {
    return TrainingData(
      trainingId: json['training_id'],
      trainerId: json['trainer_id'],
      trainerName: json['trainer_name'],
      courseName: json['course_name'],
      date: json['date'],
      time: json['time'],
      traineeName: List<String>.from(json['trainee_name']),
      traineeId: List<int>.from(json['trainee_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'training_id': trainingId,
      'trainer_id': trainerId,
      'trainer_name': trainerName,
      'course_name': courseName,
      'date': date,
      'time': time,
      'trainee_name': traineeName,
      'trainee_id': traineeId,
    };
  }
}
