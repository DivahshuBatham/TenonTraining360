import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/trainee/trainee_dashboard.dart';
import '../environment/Environment.dart';
import '../model/VirtualTrainingByTraineeResponse.dart';
import '../networking/api_config.dart';
import '../shared_preference/shared_preference_manager.dart';
import 'VideoTrainingByTrainee.dart';

class VirtualTrainingByTrainee extends StatefulWidget {
  const VirtualTrainingByTrainee({super.key});

  @override
  State<VirtualTrainingByTrainee> createState() => _VirtualTrainingByTraineeState();
}

class _VirtualTrainingByTraineeState extends State<VirtualTrainingByTrainee> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  List<VirtualTrainingData> trainingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getVirtualTrainings();
    });
  }

  Future<void> getVirtualTrainings() async {
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
        final parsed = VirtualTrainingByTraineeResponse.fromJson(responseData);
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
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  void _showJoinTrainingDialog(BuildContext context,VirtualTrainingData training){
    showDialog(
        context: context,
        builder: (BuildContext dialogContext){
          return AlertDialog(
            title: Text('Confirm Join'),
            content:Text('Are you sure you want to join this training?'),
            actions: [
              TextButton(
                  onPressed:(){Navigator.of(dialogContext).pop();},
                  child: Text('cancel')
              ),
              ElevatedButton(
                  onPressed:(){
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoTrainingByTrainee(),
                        settings: RouteSettings(arguments:{
                          'course_id': training.courseId,
                        'pdf_url': training.pdfUrl
                        })
                      ),
                    );
                    },
                  child:Text("join")
          )
            ],
          );
        }
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trainee Virtual Trainings"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TraineeDashboard() ,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              getVirtualTrainings();
            },
          ),

        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trainingList.isEmpty
          ? const Center(child: Text('No scheduled training found.'))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: trainingList.length,
        itemBuilder: (context, index) {
          final training = trainingList[index];

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
                  Text('📚 Course Name: ${training.courseName ?? "N/A"}'),
                  Text('👨‍🏫 Trainer Name: ${training.trainerName ?? "N/A"}'),
                  Text('🏢 Site Name: ${training.siteName ?? "N/A"}'),
                  Text('🧑‍🎓 Trainee Name: ${training.traineeName ?? "N/A"}'),
                  Row(
                    children: [
                      Text('📅 Date: ${formatDate(training.date)}'),
                      const SizedBox(width: 20),
                      Text('⏰ Time: ${training.time ?? "N/A"}'),
                    ],
                  ),
                  Text('📌 Training status: ${training.status ?? "N/A"}'),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      // icon: const Icon(Icons.play_arrow),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.purple
                      ),
                      label: const Text('Join Training',style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        _showJoinTrainingDialog(context,training);
                      },
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
