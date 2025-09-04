import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import '../environment/Environment.dart';
import '../model/TraineeJoinStatusResponse.dart';

class VirtualTrainingRoom extends StatefulWidget {
  const VirtualTrainingRoom({super.key});

  @override
  State<VirtualTrainingRoom> createState() => _TrainingRoomState();
}

class _TrainingRoomState extends State<VirtualTrainingRoom> {
  final Dio _dio = Dio();
  bool _loading = true;
  String? _error;
  TraineeJoinStatusResponse? _traineeStatusResponse;
  int? _trainingId;
  int? _totalTrainees;
  bool _dataFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataFetched) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _trainingId = args['trainingId'];
        _totalTrainees = args['totalTrainees'];
        fetchTraineeStatus();
        _dataFetched = true;
      } else {
        setState(() {
          _error = 'Invalid training data';
          _loading = false;
        });
      }
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
          'training_type': 'virtual',
        },
      );
      final data = resp.data;
      if (data['status'] == 200) {
        setState(() {
          _traineeStatusResponse = TraineeJoinStatusResponse.fromJson(data);
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

  Future<void> completeTraining() async {
    if (_trainingId == null) return;
    final url =
        '${AppConfig.baseUrl}${ApiConfig.updateStatusTrainer}$_trainingId/${ApiConfig.virtualType}';
    try {
      final resp = await _dio.patch(url);
      final data = resp.data;
      if (data['status'] == 200) {
        ApiConfig.showToastMessage(data['message']);
        Navigator.of(context).pop();
        fetchTraineeStatus();
      } else {
        ApiConfig.showToastMessage(
          'Failed to complete training. Status: ${resp.statusCode}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing training: $e')),
      );
    }
  }

  void _showConfirmationDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Complete Training"),
        content: const Text("Are you sure you want to complete the training?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("No")),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              completeTraining();
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
        title: const Text('Virtual Training Room'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTraineeStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course: ${_traineeStatusResponse?.courseName ?? 'N/A'}',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Trainees: ${_totalTrainees ?? '-'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Trainees Status:',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount:
                _traineeStatusResponse?.trainees.length ?? 0,
                itemBuilder: (context, i) {
                  final t = _traineeStatusResponse!.trainees[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading:
                            CircleAvatar(child: Text('${i + 1}')),
                            title: Text(
                              t.traineeName ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              t.isJoined
                                  ? 'Joined at: ${t.joinedAt ?? '-'}'
                                  : 'Not Joined Yet',
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _StatusColumn(
                                  label: 'Room Join',
                                  icon: t.isJoined
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: t.isJoined
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 20),
                                _StatusColumn(
                                  label: 'Assessment',
                                  icon: Icons.cancel,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 20),
                                _StatusColumn(
                                  label: 'Feedback',
                                  icon: Icons.cancel,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 20),
                                _StatusColumn(
                                  label: 'Exit',
                                  icon: Icons.cancel,
                                  color: Colors.red,
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showConfirmationDialog(context),
                label: const Text('Training Delivered',
                    style:
                    TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.done_all, color: Colors.white),
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
