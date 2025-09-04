import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tenon_training_app/shared_preference/shared_preference_manager.dart';
import 'assessment_by_trainee/TraineeResult.dart';
import 'environment/Environment.dart';
import 'networking/api_config.dart';

class TraineeFeedback extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const TraineeFeedback({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<TraineeFeedback> createState() => _TrainerFeedbackState();
}

class _TrainerFeedbackState extends State<TraineeFeedback> {
  bool isFeedbackCompleted = false;
  String? trainingID;
  String? traineeID;

  final sharedPreferenceManager = SharedPreferenceManager();

  List<dynamic> feedbackQuestions = []; // Will be loaded from API
  Map<int, double> selectedRatings = {}; // Store ratings

  @override
  void initState() {
    super.initState();
    loadTrainingID();
    fetchFeedbackQuestions(); // Load questions dynamically
  }

  void loadTrainingID() async {
    trainingID = await sharedPreferenceManager.getPhysicalTrainingID();
    traineeID = await sharedPreferenceManager.getTraineeID();
    setState(() {}); // Update UI after loading IDs
  }

  Future<void> fetchFeedbackQuestions() async {
    try {
      final String url = '${AppConfig.baseUrl}${ApiConfig.getFeedbackQuestions}';
      final dio = Dio();

      // Add token if required
      final token = await sharedPreferenceManager.getToken();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == true) {
        setState(() {
          feedbackQuestions = response.data['data'];
        });
      } else {
        ApiConfig.showToastMessage(response.data['message'] ?? 'Failed to load questions');
      }
    } catch (e) {
      ApiConfig.showToastMessage('Error: ${e.toString()}');
    }
  }

  void submitFeedback() {
    if (selectedRatings.length != feedbackQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate all questions')),
      );
      return;
    }

    isFeedbackCompleted = true;

    // Log feedback for debug
    selectedRatings.forEach((index, rating) {
      print("Q${index + 1}: $rating stars");
    });

    updateAssessmentStatus(trainingID!, 'physical', traineeID!, isFeedbackCompleted);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TraineeResult(
          score: widget.score,
          totalQuestions: widget.totalQuestions,
        ),
      ),
    );
  }

  Future<void> updateAssessmentStatus(
      String trainingId,
      String trainingType,
      String traineeId,
      bool isFeedbackCompleted,
      ) async {
    try {
      final String url = '${AppConfig.baseUrl}${ApiConfig.updateTraineeStatus}';
      final dio = Dio();

      final response = await dio.patch(url, data: {
        'training_id': trainingId,
        'training_type': trainingType,
        'trainee_id': traineeId,
        'is_feedback': isFeedbackCompleted,
      });

      final responseData = response.data;

      if (responseData['status'] == true) {
        ApiConfig.showToastMessage(responseData['message']);
      } else {
        ApiConfig.showToastMessage('Update failed');
      }
    } catch (e) {
      ApiConfig.showToastMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: feedbackQuestions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: feedbackQuestions.length,
          itemBuilder: (context, index) {
            final question = feedbackQuestions[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${index + 1}: ${question['question_text']}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    RatingBar.builder(
                      initialRating: selectedRatings[index] ?? 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 32,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          selectedRatings[index] = rating;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: () {
            submitFeedback();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.purple,
          ),
          child: const Text('Submit Feedback',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
