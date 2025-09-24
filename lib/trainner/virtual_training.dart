import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import 'package:tenon_training_app/shared_preference/shared_preference_manager.dart';
import 'package:tenon_training_app/trainner/ScheduleTrainingsVirtual.dart';
import '../environment/Environment.dart';
import 'ScheduleTrainingsPhysical.dart';

class VirtualTraining extends StatefulWidget {
  const VirtualTraining({Key? key}) : super(key: key);

  @override
  State<VirtualTraining> createState() => _PhysicalTrainingState();
}

class _PhysicalTrainingState extends State<VirtualTraining> {
  final Dio _dio = Dio();
  final ScrollController _scrollController = ScrollController();
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();

  List<Map<String, dynamic>> lastFetchedData = [];
  List<String> courseList = [];
  List<Map<String, String>> _courseMap = [];
  String? selectedCourse;
  bool isCourseListLoaded = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> searchableFields = [
    'Company', 'Branch_Code', 'Customer_Code', 'Site_ID', 'GS_Code'
  ];

  Map<String, String?> selectedFilters = {
    'Company': null,
    'Branch_Code': null,
    'Customer_Code': null,
    'Site_ID': null,
    'GS_Code': null,
  };

  Map<String, Set<String>> fieldValueMap = {
    'Company': {},
    'Branch_Code': {},
    'Customer_Code': {},
    'Site_ID': {},
    'GS_Code': {},
  };

  Map<String, String> _customerCodeNameMap = {};
  Map<String, String> _branchCodeNameMap = {};
  Map<String, String> _siteIdNameMap = {};
  Map<String, String> _gsCodeNameMap = {};

  @override
  void initState() {
    super.initState();
    _fetchCourseList();
    _fetchTraineesList();
  }

  Future<void> _fetchCourseList() async {
    if (isCourseListLoaded) return;
    try {
      final resp = await _dio.get(
        '${AppConfig.baseUrl}${ApiConfig.getCourse}?training_type=virtual',
      );
      final data = resp.data;
      if (data['status'] == true) {
        final names = <String>[];
        final mapTemp = <Map<String, String>>[];
        for (var c in data['data'] ?? []) {
          final n = c['course_name']?.toString();
          final i = c['id']?.toString();
          if (n != null && i != null) {
            names.add(n);
            mapTemp.add({'id': i, 'name': n});
          }
        }
        names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        setState(() {
          courseList = names;
          _courseMap = mapTemp;
          isCourseListLoaded = true;
        });
      } else {
        ApiConfig.showToastMessage('No course data found.');
      }
    } catch (_) {
      ApiConfig.showToastMessage('Failed to load courses.');
    }
  }

  Future<void> _fetchTraineesList() async {
    try {
      final resp = await _dio.get('${AppConfig.baseUrl}${ApiConfig.getTrainees}');
      if (resp.statusCode == 200) {
        lastFetchedData = List<Map<String, dynamic>>.from(resp.data['data']);

        _customerCodeNameMap.clear();
        _branchCodeNameMap.clear();
        _siteIdNameMap.clear();
        _gsCodeNameMap.clear();

        for (var r in lastFetchedData) {
          final cCode = r['Customer_Code']?.toString();
          final cName = r['Customer_Name']?.toString();
          if (cCode != null && cName != null) {
            _customerCodeNameMap[cCode] = cName;
          }

          final bCode = r['Branch_Code']?.toString();
          final bName = r['Branch_Name']?.toString();
          if (bCode != null && bName != null) {
            _branchCodeNameMap[bCode] = bName;
          }

          final sId = r['Site_ID']?.toString();
          final sName = r['Site_Name']?.toString();
          if (sId != null && sName != null) {
            _siteIdNameMap[sId] = sName;
          }

          final gsCode = r['GS_Code']?.toString();
          final gsName = r['GS_Name']?.toString();
          if (gsCode != null && gsName != null) {
            _gsCodeNameMap[gsCode] = gsName;
          }
        }

        setState(() {
          for (var f in searchableFields) {
            fieldValueMap[f] = _getFilteredFieldValues(f);
          }
        });
      }
    } catch (_) {
      ApiConfig.showToastMessage('Failed to load trainees.');
    }
  }

  Set<String> _getFilteredFieldValues(String field) {
    var filtered = lastFetchedData;
    for (var f in searchableFields) {
      if (f == field) break;
      final val = selectedFilters[f];
      if (val != null) {
        if (f == 'GS_Code') {
          final parts = val.split(',');
          filtered = filtered.where((r) => parts.contains(r[f]?.toString())).toList();
        } else {
          filtered = filtered.where((r) => r[f]?.toString() == val).toList();
        }
      }
    }
    return filtered.map((r) => r[field]?.toString() ?? '').where((v) => v.isNotEmpty).toSet();
  }

  void _onFilterChanged(String field, String? value) {
    setState(() {
      selectedFilters[field] = value == '' ? null : value;
      final idx = searchableFields.indexOf(field);
      for (int i = idx + 1; i < searchableFields.length; i++) {
        selectedFilters[searchableFields[i]] = null;
        fieldValueMap[searchableFields[i]] = {};
      }
      for (var f in searchableFields) {
        fieldValueMap[f] = _getFilteredFieldValues(f);
      }
    });
  }

  void _showGSCodeDialog() async {
    final gsCodes = fieldValueMap['GS_Code']!.toList()
      ..sort((a, b) => (_gsCodeNameMap[a] ?? '').compareTo(_gsCodeNameMap[b] ?? ''));

    final current = selectedFilters['GS_Code']?.split(',').toSet() ?? {};
    final selected = Set<String>.from(current);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) => AlertDialog(
          title: const Text('Select GS_Code(s)'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => setD(() => selected.addAll(gsCodes)), child: const Text('Select All')),
                    TextButton(onPressed: () => setD(selected.clear), child: const Text('Unselect All')),
                  ],
                ),
                const Divider(),
                ...gsCodes.map((c) => CheckboxListTile(
                  title: Text('${_gsCodeNameMap[c] ?? ''} ($c)'),
                  value: selected.contains(c),
                  onChanged: (b) => setD(() {
                    if (b == true) selected.add(c);
                    else selected.remove(c);
                  }),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final join = selected.join(',');
                Navigator.pop(ctx);
                _onFilterChanged('GS_Code', join.isEmpty ? null : join);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final sel = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (sel != null) {
      setState(() => _selectedDate = sel);
    }
  }

  Future<void> _selectTime() async {
    final now = TimeOfDay.now();
    final sel = await showTimePicker(context: context, initialTime: _selectedTime ?? now);
    if (sel != null) {
      setState(() => _selectedTime = sel);
    }
  }

  Future<void> scheduleVirtual() async {
    if (_selectedDate == null || _selectedTime == null) {
      ApiConfig.showToastMessage('Please select date and time.');
      return;
    }
    if (selectedCourse == null) {
      ApiConfig.showToastMessage('Please select a course.');
      return;
    }

    final entry = _courseMap.firstWhere(
          (e) => e['name'] == selectedCourse,
      orElse: () => {'id': '0'},
    );
    final cid = int.tryParse(entry['id']!) ?? 0;
    if (cid == 0) {
      ApiConfig.showToastMessage('Invalid course.');
      return;
    }

    final filtered = lastFetchedData.where((r) {
      return searchableFields.every((f) {
        final val = selectedFilters[f];
        if (val == null) return true;
        if (f == 'GS_Code') return val.split(',').contains(r[f]?.toString());
        return r[f]?.toString() == val;
      });
    }).toList();

    if (filtered.isEmpty) {
      ApiConfig.showToastMessage('No trainees match selected filters.');
      return;
    }

    final token = await _preferenceManager.getToken();
    final formattedDate =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    final requestData = {
      'course_name': selectedCourse,
      'course_id': cid,
      'date': formattedDate,
      'time': formattedTime,
      'trainee_name':
      filtered.map((e) => e['GS_Name'].toString()).toList(),
      'site_id': selectedFilters['Site_ID'],
      'site_name': _siteIdNameMap[selectedFilters['Site_ID']] ?? '',
    };

    try {
      debugPrint("📤 API Request URL: ${AppConfig.baseUrl}${ApiConfig.scheduleVirtualTraining}");
      debugPrint("🔑 Token: $token");
      debugPrint("📦 Request Data: $requestData");

      final response = await _dio.post(
        '${AppConfig.baseUrl}${ApiConfig.scheduleVirtualTraining}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: requestData,
      );

      debugPrint("📥 Raw Response: ${response.data}");

      final responseData = response.data;
      if (responseData['status'] == 200) {
        await _preferenceManager
            .saveTrainerId(responseData['trainer_id'].toString());
        ApiConfig.showToastMessage(responseData['message']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ScheduleTrainingsVirtual()),
        );
      }
      else {
        ApiConfig.showToastMessage(
          responseData['message'] ?? 'Failed to schedule training.',
        );
      }
    } on DioException catch (e) {
      debugPrint("❌ Dio error: ${e.message}");
      debugPrint("❌ Response: ${e.response?.data}");
      debugPrint("❌ Status code: ${e.response?.statusCode}");
      debugPrint("❌ Request options: ${e.requestOptions}");
      ApiConfig.showToastMessage(
        "API Error: ${e.response?.statusCode ?? ''} ${e.message}",
      );
    } catch (e, stack) {
      debugPrint("❌ Unexpected error: $e");
      debugPrint("❌ Stacktrace: $stack");
      ApiConfig.showToastMessage("Unexpected error: $e");
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Training')),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var field in searchableFields)
                field == 'GS_Code'
                    ? ListTile(
                  title: const Text('Emp Name'),
                  subtitle: Text(
                    selectedFilters['GS_Code'] == null
                        ? 'Select Emp Name'
                        : selectedFilters['GS_Code']!
                        .split(',')
                        .map((code) => '${_gsCodeNameMap[code] ?? ''} ($code)')
                        .join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _showGSCodeDialog,
                )
                    : DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: field == 'Customer_Code'
                        ? 'Customer Name'
                        : field == 'Branch_Code'
                        ? 'Branch Name'
                        : field == 'Site_ID'
                        ? 'Site Name'
                        : field,
                  ),
                  value: selectedFilters[field],
                  items: (() {
                    final unsorted = fieldValueMap[field]!.toList();
                    if (field == 'Customer_Code') {
                      unsorted.sort((a, b) =>
                          (_customerCodeNameMap[a] ?? '').compareTo(_customerCodeNameMap[b] ?? ''));
                      return unsorted.map((code) {
                        final name = _customerCodeNameMap[code] ?? '';
                        return DropdownMenuItem(value: code, child: Text('$name ($code)'));
                      }).toList();
                    } else if (field == 'Branch_Code') {
                      unsorted.sort(); // ✅ Sort by Branch_Code
                      return unsorted.map((code) {
                        final name = _branchCodeNameMap[code] ?? '';
                        return DropdownMenuItem(value: code, child: Text('$name $code'));
                      }).toList();
                    } else if (field == 'Site_ID') {
                      unsorted.sort((a, b) =>
                          (_siteIdNameMap[a] ?? '').compareTo(_siteIdNameMap[b] ?? ''));
                      return unsorted.map((id) {
                        final name = _siteIdNameMap[id] ?? '';
                        return DropdownMenuItem(value: id, child: Text('$name ($id)'));
                      }).toList();
                    } else {
                      unsorted.sort();
                      return unsorted.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList();
                    }
                  })(),
                  onChanged: (val) => _onFilterChanged(field, val),
                  isExpanded: true,
                ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Course'),
                value: selectedCourse,
                items: courseList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedCourse = v),
                isExpanded: true,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectDate,
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text('Date', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectTime,
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text('Time', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_selectedDate != null)
                    Text(
                      "Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),

                  if (_selectedTime != null)
                    Text(
                      "Time: ${_selectedTime!.format(context)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),

                ],

              ),

              // ✅ Show selected date & time

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: scheduleVirtual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Schedule Training', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
