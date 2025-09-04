class QuestionsResponse {
    QuestionsResponse({
        required this.data,
        required this.status,
    });

    List<Datum> data;
    bool status;

    factory QuestionsResponse.fromJson(Map<String, dynamic> json) =>
        QuestionsResponse(
            data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
            status: json["status"],
        );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
    };
}

class Datum {
    Datum({
        required this.optionD,
        required this.correctOption,
        required this.optionB,
        required this.optionC,
        required this.question,
        required this.updatedAt,
        required this.createdAt,
        required this.id,
        required this.optionA,
    });

    String optionD;
    CorrectOption correctOption;
    String optionB;
    String optionC;
    String question;
    DateTime updatedAt;
    DateTime createdAt;
    int id;
    String optionA;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        optionD: json["option_d"],
        correctOption: correctOptionValues.map[json["correct_option"]]!,
        optionB: json["option_b"],
        optionC: json["option_c"],
        question: json["question"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
        optionA: json["option_a"],
    );

    Map<String, dynamic> toJson() => {
        "option_d": optionD,
        "correct_option": correctOptionValues.reverse[correctOption],
        "option_b": optionB,
        "option_c": optionC,
        "question": question,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "id": id,
        "option_a": optionA,
    };
}

enum CorrectOption { A, B, C, D }

final correctOptionValues = EnumValues({
    "a": CorrectOption.A,
    "b": CorrectOption.B,
    "c": CorrectOption.C,
    "d": CorrectOption.D,
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}

// 🔽 Extension to easily get options list and correct answer index
extension DatumExtension on Datum {
    List<String> get options => [optionA, optionB, optionC, optionD];

    int get correctAnswerIndex {
        switch (correctOption) {
            case CorrectOption.A:
                return 0;
            case CorrectOption.B:
                return 1;
            case CorrectOption.C:
                return 2;
            case CorrectOption.D:
                return 3;
        }
    }
}
