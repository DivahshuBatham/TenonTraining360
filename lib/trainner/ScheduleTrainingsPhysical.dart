import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/trainner/physical_training.dart';
import '../environment/Environment.dart';
import '../model/PhysicalTrainingByTrainerResponse.dart';
import '../networking/api_config.dart';
import '../shared_preference/shared_preference_manager.dart';
import 'PhysicalTrainingRoom.dart';

class ScheduleTrainingsPhysical extends StatefulWidget {
  const ScheduleTrainingsPhysical({super.key});

  @override
  State<ScheduleTrainingsPhysical> createState() => _ScheduleTrainingsPhysicalState();
}

class _ScheduleTrainingsPhysicalState extends State<ScheduleTrainingsPhysical> {
  List<PhysicalTrainingByTrainer> trainingList = [];
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPhysicalTrainings();
    });
  }

  Future<void>  getPhysicalTrainings() async {
    final id = await _preferenceManager.getTrainerID();
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
        final parsed = PhysicalTrainingByTrainerResponse.fromJson(responseData);
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


  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(dateString);
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  Widget trainingCard(PhysicalTrainingByTrainer training) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.meeting_room),
                  label: const Text('Training Room', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogCtx) {
                        return AlertDialog(
                          title: const Text("Join Training"),
                          content: const Text("Are you sure you want to join this training?"),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(dialogCtx).pop();
                              },
                            ),
                            ElevatedButton(
                              child: const Text("Join"),
                              onPressed: () {
                                Navigator.of(dialogCtx).pop(); // Close dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PhysicalTrainingRoom(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'trainingId': training.id,
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('👨‍🏫 Course Name: ${training.courseName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('📚 Trainer Name: ${training.trainerName}'),
            Text('🏢 Site Name: ${training.siteName}'),
            Text('👥 Total Trainees: ${training.totalTrainees}'),
            const SizedBox(height: 4),
            Text('📅 Training Date: ${formatDate(training.date)}'),
            const SizedBox(height: 4),
            Text('⏰ Time: ${training.time}'),
            Text('📌 Status: ${training.status}'),
            Text('✅ Total Attendance: ${training.totalAttendance}'),
            // Text('✅ Not Joined: ${training.notJoined}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Physical Trainer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
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
        padding: const EdgeInsets.all(12),
        itemCount: trainingList.length,
        itemBuilder: (context, index) {
          return trainingCard(trainingList[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhysicalTraining()),
          ).then((_) {
            setState(() => isLoading = true);
            getPhysicalTrainings();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("Schedule Training"),
      ),
    );
  }
}
