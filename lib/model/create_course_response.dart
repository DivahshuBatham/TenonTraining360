    class CreateCourseResponse {
    CreateCourseResponse({
        required this.data,
        required this.message,
        required this.status,
    });

    List<Datum> data;
    String message;
    int status;

    factory CreateCourseResponse.fromJson(Map<dynamic, dynamic> json) => CreateCourseResponse(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        message: json["message"],
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "status": status,
    };
}

class Datum {
    Datum({
        required this.updatedAt,
        required this.traineeName,
        required this.id,
        required this.trainerName,
        this.coursesName,
        this.trainingUrl,
    });

    DateTime updatedAt;
    String traineeName;
    int id;
    String trainerName;
    String? coursesName;
    String? trainingUrl;

    factory Datum.fromJson(Map<dynamic, dynamic> json) => Datum(
        updatedAt: DateTime.parse(json["updated_at"]),
        traineeName: json["trainee_name"],
        id: json["id"],
        trainerName: json["trainer_name"],
        coursesName: json["courses_name"],
        trainingUrl: json["training_url"],
    );

    Map<dynamic, dynamic> toJson() => {
        "updated_at": updatedAt.toIso8601String(),
        "trainee_name": traineeName,
        "id": id,
        "trainer_name": trainerName,
        "courses_name": coursesName,
        "training_url": trainingUrl,
    };
}
