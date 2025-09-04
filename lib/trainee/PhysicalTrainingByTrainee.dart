import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../environment/Environment.dart';
import '../model/PhysicalTrainingByTraineeResponse.dart';
import '../networking/api_config.dart';
import '../shared_preference/shared_preference_manager.dart';
import 'PhysicalPdfViewerScreen.dart';

class PhysicalTrainingByTrainee extends StatefulWidget {
  const PhysicalTrainingByTrainee({super.key});

  @override
  State<PhysicalTrainingByTrainee> createState() => _PhysicalTrainingByTraineeState();
}

class _PhysicalTrainingByTraineeState extends State<PhysicalTrainingByTrainee> {
  List<PhysicalTrainingByTraineeData> trainingList = [];
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  bool isLoading = true;
  final Set<int> joinedTrainings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getPhysicalTrainings());
  }

  Future<void>  getPhysicalTrainings() async {
    final id = await _preferenceManager.getTraineeID();
    final token = await _preferenceManager.getToken();

    if (id == null || id.isEmpty || token == null || token.isEmpty) {
      ApiConfig.showToastMessage('Trainer ID or token is missing.');
      setState(() {
        trainingList = [];
        isLoading = false;
      });
      return;
    }

    final String url = '${AppConfig.baseUrl}${ApiConfig.getPhysicalTrainingByTrainerId}$id';
    debugPrint('Fetching virtual trainings for Trainer ID: $id');
    debugPrint('URL: $url');

    try {
      Dio dio = Dio(BaseOptions(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.get(url).timeout(const Duration(seconds: 10));
      final responseData = response.data;
      debugPrint('Response: $responseData');

      if (response.statusCode == 200 && responseData['status'] == true) {
        final parsed = PhysicalTrainingByTraineeResponse.fromJson(responseData);
        setState(() {
          trainingList = parsed.data;
        });
      } else {
        final message = responseData['message'] ?? 'Something went wrong';
        ApiConfig.showToastMessage(message);
        setState(() {
          trainingList = [];
        });
      }
    } on DioException catch (e) {
      debugPrint('DioException: $e');

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (statusCode == 404) {
        final message = responseData?['message'] ?? 'No virtual trainings found.';
        ApiConfig.showToastMessage(message);
      } else {
        ApiConfig.showToastMessage('Network error: ${e.message}');
      }

      setState(() {
        trainingList = [];
      });
    } catch (e) {
      debugPrint('Unexpected error: $e');
      ApiConfig.showToastMessage('Unexpected error: ${e.toString()}');
      setState(() {
        trainingList = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> joinTraining(int trainingId, int traineeId, String trainingType) async {
    try {
      final prefManager = SharedPreferenceManager();
      final token = await prefManager.getToken();

      final String url = '${AppConfig.baseUrl}${ApiConfig.checkMarkJoin}';

      final dio = Dio(BaseOptions(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }));

      final response = await dio.post(
        url,
        data: {
          'training_id': trainingId,
          'trainee_id': traineeId,
          'training_type': trainingType,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        debugPrint('Join training response: $responseData');

        ApiConfig.showToastMessage("${responseData['message']}");
        final String trainingID = trainingId.toString();
        debugPrint('Training ID: $trainingId');
        _preferenceManager.savePhysicalTrainingID(trainingID);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PhysicalPdfViewerScreen(),
              settings: RouteSettings(arguments:trainingList.firstWhere((element) => element.id == trainingId).pdfUrl)
          ),
        );
        setState(() {
          joinedTrainings.add(trainingId);
        });
      } else {
        throw Exception("Failed to join training: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Join training error: $e');
      ApiConfig.showToastMessage("Error joining training: ${e.toString()}");
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(dateString);
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trainee Trainings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                joinedTrainings.clear();
              });
              getPhysicalTrainings();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trainingList.isEmpty
          ? const Center(child: Text('No scheduled training found.'))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: trainingList.length,
        itemBuilder: (context, index) {
          final training = trainingList[index];
          final isJoined = joinedTrainings.contains(training.id ?? -1);

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📚 Course Name: ${training.courseName ?? "N/A"}'),
                  Text('👨‍🏫 Trainer: ${training.trainerName ?? "N/A"}'),
                  Text('📍 Site Name: ${training.siteName ?? "N/A"}'),
                  Text('🧑‍🎓 Trainee Name: ${training.traineeName ?? "N/A"}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('📅 Date: ${formatDate(training.date.toString())}'),
                      const SizedBox(width: 20),
                      Text('⏰ Time: ${training.time}'),
                    ],
                  ),
                  Text('📌 Training Status: ${training.status ?? "N/A"}'),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: Icon(isJoined ? Icons.check_circle : Icons.play_arrow),
                      label: Text(isJoined ? 'Joined' : 'Join Training'),
                      onPressed: (!isJoined &&
                          training.id != null &&
                          training.traineeId != null)
                          ? () => joinTraining(training.id, training.traineeId, "physical")
                          : null,
                    ),
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
