import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tenon_training_app/networking/api_config.dart';
import '../environment/Environment.dart';
import '../model/questions_response.dart';

class QuestionService {
  static Future<List<Datum>> fetchQuestions() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}${ApiConfig.mcqQuestion}'));

    if (response.statusCode == 200) {
      final parsed = QuestionsResponse.fromJson(jsonDecode(response.body));
      return parsed.data;
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
