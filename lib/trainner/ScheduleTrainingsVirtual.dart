import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/l10n/app_localizations.dart';
import 'package:tenon_training_app/model/VirtualTrainingByTrainerResponse.dart';
import 'package:tenon_training_app/trainner/VirtualTrainingRoom.dart';
import 'package:tenon_training_app/trainner/virtual_training.dart';
import '../environment/Environment.dart';
import '../networking/api_config.dart';
import '../shared_preference/shared_preference_manager.dart';

class ScheduleTrainingsVirtual extends StatefulWidget {
  const ScheduleTrainingsVirtual({super.key});

  @override
  State<ScheduleTrainingsVirtual> createState() => _ScheduleTrainingsVirtualState();
}

class _ScheduleTrainingsVirtualState extends State<ScheduleTrainingsVirtual> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  List<TrainingData> trainingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getVirtualTrainings();
    });
  }

  Future<void> getVirtualTrainings() async {
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

    try {
      final String url = '${AppConfig.baseUrl}${ApiConfig.getVirtualTrainingById}$id';
      debugPrint('Fetching trainings for Trainer ID: $id');
      debugPrint('URL: $url');

      Dio dio = Dio(BaseOptions(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }));

      final response = await dio.get(url).timeout(const Duration(seconds: 10));
      final responseData = response.data;
      debugPrint('Response: $responseData');

      if (response.statusCode == 200 && responseData['status'] == true) {
        final parsed = VirtualTrainingByTrainerResponse.fromJson(responseData);
        setState(() {
          trainingList = parsed.data;
        });
      } else {
        ApiConfig.showToastMessage(responseData['message'] ?? 'Something went wrong');
        setState(() {
          trainingList = [];
        });
      }
    } on DioException catch (e) {
      debugPrint('DioException: $e');

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      if (statusCode == 404) {
        final message = responseData?['message'] ?? 'No trainings found.';
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
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  Widget trainingCard(TrainingData training, int index) {
    final local = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for "Join Training" button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.meeting_room),
                  label: const Text('Training Room',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VirtualTrainingRoom(),
                        settings: RouteSettings(
                          arguments: {
                            'trainingId': training.id,
                            'totalTrainees': training.totalTrainees,
                          },
                        ),
                      ),
                    );

                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('📘 ${local.courseName}: ${training.courseName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('👨‍🏫 ${local.trainerName}: ${training.trainerName}'),
            Text('🏢 ${local.siteName}: ${training.siteName}'),
            Text('👥 ${local.totalTrainees}: ${training.totalTrainees}'),
            Row(
              children: [
                Text('📅 ${local.date}: ${formatDate(training.date)}'),
                const SizedBox(width: 20),
                Text('⏰ ${local.time}: ${training.time}'),
              ],
            ),
            Text('📌 ${local.trainingStatus}: ${training.status}'),
            Text('📋 ${local.totalAttendance}: ${training.totalAttendance}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual Trainings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              getVirtualTrainings();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trainingList.isEmpty
          ? const Center(child: Text('No virtual trainings found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: trainingList.length,
        itemBuilder: (context, index) {
          return trainingCard(trainingList[index], index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const VirtualTraining()),
          ).then((updated) {
            if (updated == true) {
              setState(() => isLoading = true);
              getVirtualTrainings();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("Schedule Training"),
      ),
    );
  }
}
