import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import '../TraineeFeedback.dart';
import '../environment/Environment.dart';
import '../model/questions_response.dart';
import '../shared_preference/shared_preference_manager.dart';
import 'QuestionService.dart';
import 'widgets/answer_card.dart';
import 'widgets/next_button.dart';

class TraineeAssessment extends StatefulWidget {
  const TraineeAssessment({super.key});

  @override
  State<TraineeAssessment> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<TraineeAssessment> {
  int? selectedAnswerIndex;
  int questionIndex = 0;
  int score = 0;
  late Future<List<Datum>> futureQuestions;
  List<Datum> questions = [];
  bool isAssessmentCompleted = false;
  String? trainingID;
  String? traineeID;

  final sharedPreferenceManager = SharedPreferenceManager();

  @override
  void initState() {
    super.initState();
    futureQuestions = QuestionService.fetchQuestions();
    loadTrainingID();
  }

  void loadTrainingID() async {
    trainingID = await sharedPreferenceManager.getPhysicalTrainingID();
    traineeID = await sharedPreferenceManager.getTraineeID();
    setState(() {}); // To update the UI if needed
  }

  void pickAnswer(int index) {
    final currentQuestion = questions[questionIndex];

    setState(() {
      // Adjust score if user changes answer
      if (selectedAnswerIndex != null) {
        if (selectedAnswerIndex == currentQuestion.correctAnswerIndex) {
          score--;
        }
      }

      selectedAnswerIndex = index;

      if (index == currentQuestion.correctAnswerIndex) {
        score++;
      }
    });
  }

  void goToNextQuestion() {
    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
        selectedAnswerIndex = null;
      });
    }
  }

  Future<void> updateAssessmentStatus(String trainingId,String trainingType,String traineeId,bool isAssessmentCompleted) async{

    try{
      final String url = '${AppConfig.baseUrl}''${ApiConfig.updateTraineeStatus}';
      final dio = Dio();

      final response = await dio.patch(url,data: {
        'training_id':trainingId,
        'training_type':trainingType,
        'trainee_id':traineeId,
        'is_assessment':isAssessmentCompleted
      });

      final responseData = response.data;


      if(responseData['status']==true){

        ApiConfig.showToastMessage(responseData['message']);
      }

    }catch(e){
      
      ApiConfig.showToastMessage(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Datum>>(
        future: futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions found.'));
          }

          if (questions.isEmpty) {
            questions = snapshot.data!;
          }

          final question = questions[questionIndex];
          final isLastQuestion = questionIndex == questions.length - 1;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${questionIndex + 1} of ${questions.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 21),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    question.options.length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: AnswerCard(
                        currentIndex: index,
                        optionText: question.options[index],
                        isSelected: selectedAnswerIndex == index,
                        selectedAnswerIndex: selectedAnswerIndex,
                        correctAnswerIndex: question.correctAnswerIndex,
                        onTap: () => pickAnswer(index),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  isLastQuestion
                      ? RectangularButton(
                    onPressed: selectedAnswerIndex != null
                        ? () {
                      debugPrint('trainingID==:$trainingID, traineeID==:$traineeID');
                      isAssessmentCompleted = true;
                      updateAssessmentStatus(trainingID!,'physical' ,traineeID!, isAssessmentCompleted);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TraineeFeedback(
                            score: score,
                            totalQuestions: questions.length,
                          ),
                        ),
                      );
                    }
                        : null,
                    label: 'Finish',
                  )
                      : RectangularButton(
                    onPressed: () {
                      if (selectedAnswerIndex != null) {
                        goToNextQuestion();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select one option'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    label: 'Next',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
