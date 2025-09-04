import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import '../environment/Environment.dart';
import '../shared_preference/shared_preference_manager.dart';
import '../trainner/trainer_dashboard.dart';

class CreateCourse extends StatefulWidget {
  const CreateCourse({super.key});

  @override
  State<CreateCourse> createState() => _CreateCourseState();
}

class _CreateCourseState extends State<CreateCourse> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _trainerNameController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _minTimeController = TextEditingController();

  String? _selectedTrainingType;
  final List<String> _trainingTypes = ['Virtual', 'Physical'];

  File? _pdfFile;

  Dio? _dio;
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDio();
  }

  Future<void> _initDio() async {
    String? token = await _preferenceManager.getToken();
    setState(() {
      _token = token;
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _descriptionController.dispose();
    _trainerNameController.dispose();
    _videoUrlController.dispose();
    _durationController.dispose();
    _minTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

          Future<void> _submitForm() async {
            if (_dio == null || _token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please wait... initializing')),
              );
              return;
            }

            if (_formKey.currentState!.validate()) {
              try {
                FormData formData = FormData.fromMap({
                  'course_name': _courseNameController.text,
                  'training_type': _selectedTrainingType?.toLowerCase(),
                  'video_url': (_selectedTrainingType == 'Virtual')
                      ? _videoUrlController.text
                      : null,
                  'duration': _durationController.text,
                  'min_time': _minTimeController.text,
                  if (_pdfFile != null)
                    'pdf_file': await MultipartFile.fromFile(
                      _pdfFile!.path,
                      filename: _pdfFile!.path.split('/').last,
                      contentType: MediaType('application', 'pdf'),
                    ),
                });

                final response = await _dio!.post(ApiConfig.createCourse, data: formData);
                final responseData = response.data;

                if (responseData['status'] == true) {
                  ApiConfig.showToastMessage(responseData['message']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrainerDashboard()),
                  );

                  _formKey.currentState!.reset();
                  setState(() {
                    _selectedTrainingType = null;
                    _pdfFile = null;
                    _videoUrlController.clear();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${response.data['message']}')),
                  );
                }
              } on DioException catch (e) {
                String errorMsg = e.response?.data?['message'] ?? 'Something went wrong';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed: $errorMsg')),
                );
              }
            }
          }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter course name' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Training Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTrainingType,
                items: _trainingTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTrainingType = value;
                    _pdfFile = null;
                    _videoUrlController.clear();
                  });
                },
                validator: (value) =>
                value == null ? 'Select training type' : null,
              ),
              const SizedBox(height: 12),

              if (_selectedTrainingType == 'Virtual') ...[
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Video URL',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedTrainingType == 'Virtual' &&
                        (value == null || value.isEmpty)) {
                      return 'Enter video URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (in minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter duration' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _minTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Time Required (in minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter minimum time' : null,
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _pickPDF,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload PDF'),
              ),
              if (_pdfFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Selected PDF: ${_pdfFile!.path.split('/').last}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
