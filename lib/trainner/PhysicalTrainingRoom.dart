import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import '../environment/Environment.dart';
import '../model/PhysicalTrainingByTrainerResponse.dart';
import '../model/TraineeJoinStatusResponse.dart';
import '../shared_preference/shared_preference_manager.dart';

class PhysicalTrainingRoom extends StatefulWidget {
  const PhysicalTrainingRoom({super.key});

  @override
  State<PhysicalTrainingRoom> createState() => _TrainingRoomState();
}

class _TrainingRoomState extends State<PhysicalTrainingRoom> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final Dio _dio = Dio();
  bool _loading = true;
  String? _error;
  TraineeJoinStatusResponse? _traineeStatusResponse;
  int? _trainingId;
  int? _notJoined;
  int? _totalTrainees;
  List<PhysicalTrainingByTrainer> trainingList = [];
  bool _dataFetched = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPhysicalTrainings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataFetched) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _trainingId = args['trainingId'];
        _dataFetched = true;
      } else {
        setState(() {
          _error = 'Invalid training data';
          _loading = false;
        });
      }
    }
  }

  Future<void> getPhysicalTrainings() async {
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

    try {
      Dio dio = Dio(BaseOptions(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.get(url).timeout(const Duration(seconds: 10));
      final responseData = response.data;

      if (response.statusCode == 200 && responseData['status'] == true) {
        final parsed = PhysicalTrainingByTrainerResponse.fromJson(responseData);
        setState(() {
          trainingList = parsed.data;
          if (_trainingId != null) {
            final matched = parsed.data.firstWhere(
                  (t) => t.id == _trainingId,
              orElse: () => parsed.data.first,
            );
            _totalTrainees = matched.totalTrainees;
            _notJoined = matched.notJoined;
          }
        });
        fetchTraineeStatus();
      } else {
        final message = responseData['message'] ?? 'Something went wrong';
        ApiConfig.showToastMessage(message);
        setState(() {
          trainingList = [];
        });
      }
    } catch (e) {
      ApiConfig.showToastMessage('Error: ${e.toString()}');
      setState(() {
        trainingList = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTraineeStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await _dio.get(
        '${AppConfig.baseUrl}${ApiConfig.traineesStatus}',
        queryParameters: {
          'training_id': _trainingId,
          'training_type': 'physical',
        },
      );
      if (resp.statusCode == 200) {
        setState(() {
          _traineeStatusResponse = TraineeJoinStatusResponse.fromJson(resp.data);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch data. Status code: ${resp.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  void _showNotJoinedPopup(List<String> notJoinedNames) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Not Joined Trainees"),
        content: SizedBox(
          width: double.maxFinite,
          child: notJoinedNames.isNotEmpty
              ? ListView.builder(
            shrinkWrap: true,
            itemCount: notJoinedNames.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(notJoinedNames[index]),
              );
            },
          )
              : const Text("No trainees found."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> completeTraining() async {
    if (_trainingId == null) return;
    final url =
        '${AppConfig.baseUrl}${ApiConfig.updateStatusTrainer}$_trainingId/${ApiConfig.physicalType}';
    try {
      final response = await _dio.patch(url);
      final data = response.data;
      if (data['status'] == 200) {
        ApiConfig.showToastMessage(data['message']);
        Navigator.of(context).pop();
        fetchTraineeStatus();
      } else {
        ApiConfig.showToastMessage('Failed to complete training. Status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing training: $e')));
    }
  }

  void _showConfirmationDialog(BuildContext ctx, VoidCallback onConfirm) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Complete Training"),
        content: const Text("Are you sure you want to complete the training?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("No")),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Room'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await getPhysicalTrainings();
              await fetchTraineeStatus();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course: ${_traineeStatusResponse?.courseName ?? 'N/A'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Trainees: ${_totalTrainees ?? '-'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Not joined: ${_notJoined ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),
                if (_notJoined != null && _notJoined! > 0)
                  TextButton(
                    onPressed: () {
                      final matched = trainingList.firstWhere(
                            (t) => t.id == _trainingId,
                        orElse: () => trainingList.first,
                      );
                      _showNotJoinedPopup(matched.notJoinedTraineeNames);
                    },
                    child: const Text(
                      "Not Join",
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Trainees Status:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _traineeStatusResponse?.trainees.length ?? 0,
                itemBuilder: (context, i) {
                  final t = _traineeStatusResponse!.trainees[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 20,
                              child: Text('${i + 1}'),
                            ),
                            title: Text(
                              t.traineeName ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              t.isJoined
                                  ? 'Joined at: ${t.joinedAt ?? '-'}'
                                  : 'Not Joined Yet',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _StatusColumn(
                                  label: 'Room Join',
                                  icon: t.isJoined ? Icons.check_circle : Icons.cancel,
                                  color: t.isJoined ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 20),
                                _StatusColumn(
                                  label: 'Assessment',
                                  icon:
                                  t.isAssessment ? Icons.check_circle : Icons.cancel,
                                  color: t.isAssessment ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 20),
                                _StatusColumn(
                                  label: 'Feedback',
                                  icon: t.isFeedback ? Icons.check_circle : Icons.cancel,
                                  color: t.isFeedback ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 20),
                                _StatusColumn(
                                  label: 'Exit',
                                  icon: t.isExit ? Icons.check_circle : Icons.cancel,
                                  color: t.isExit ? Colors.green : Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showConfirmationDialog(context, completeTraining),
                label: const Text(
                  'Training Delivered',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusColumn({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Icon(icon, color: color, size: 20),
      ],
    );
  }
}
