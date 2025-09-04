import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import 'package:tenon_training_app/shared_preference/shared_preference_manager.dart';
import 'package:tenon_training_app/trainner/ScheduleTrainingsVirtual.dart';

import '../environment/Environment.dart';


class VirtualTraining extends StatefulWidget {
  const VirtualTraining({Key? key}) : super(key: key);

  @override
  State<VirtualTraining> createState() => _VirtualTrainingState();
}

class _VirtualTrainingState extends State<VirtualTraining> {
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
  final Dio _dio = Dio();

  List<Map<String, dynamic>> lastFetchedData = [];
  List<String> courseList = [];
  List<Map<String, String>> _courseMap = [];
  String? selectedCourse;
  bool isCourseListLoaded = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> searchableFields = [
    'Company',
    'Branch_Code',
    'Customer_Code',
    'Site_ID',
    'GS_Code'
  ];

  late Map<String, String?> selectedFilters;
  late Map<String, List<String>> fieldValueMap;

  Map<String, String> customerMap = {};
  Map<String, String> siteMap = {};
  Map<String, String> branchMap = {};

  @override
  void initState() {
    super.initState();
    selectedFilters = {for (var f in searchableFields) f: null};
    fieldValueMap = {for (var f in searchableFields) f: []};
    _fetchTraineesList();
    _fetchCourseList();
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
      final resp = await _dio.get('${AppConfig.baseUrl}${ApiConfig.filterTraineeList}');
      final data = resp.data;
      if (resp.statusCode == 200 && data['status'] == 200) {
        lastFetchedData = List<Map<String, dynamic>>.from(data['data']);
        for (var e in lastFetchedData) {
          final c = e['Customer_Code']?.toString();
          final cn = e['Customer_Name']?.toString();
          if (c?.isNotEmpty == true && cn?.isNotEmpty == true) customerMap[c!] = cn!;
          final s = e['Site_ID']?.toString();
          final sn = e['Site_Name']?.toString();
          if (s?.isNotEmpty == true && sn?.isNotEmpty == true) siteMap[s!] = sn!;
          final b = e['Branch_Code']?.toString();
          final bn = e['Branch_Name']?.toString();
          if (b?.isNotEmpty == true && bn?.isNotEmpty == true) branchMap[b!] = bn!;
        }
        setState(() {
          for (var f in searchableFields) {
            final vals = lastFetchedData
                .map((e) => e[f]?.toString() ?? '')
                .where((v) => v.isNotEmpty)
                .toSet()
                .toList()
              ..sort((a, b) => _labelForField(f, a).compareTo(_labelForField(f, b)));
            fieldValueMap[f] = vals;
          }
        });
      }
    } catch (_) {
      ApiConfig.showToastMessage('Failed to load trainees.');
    }
  }

  String _labelForField(String f, String v) {
    if (f == 'Customer_Code') return customerMap[v] ?? v;
    if (f == 'Site_ID') return siteMap[v] ?? v;
    if (f == 'Branch_Code') return branchMap[v] ?? v;
    if (f == 'GS_Code') {
      final e = lastFetchedData.firstWhere((e) => e['GS_Code']?.toString() == v, orElse: () => {});
      return e['GS_Name']?.toString() ?? v;
    }
    return v;
  }

  void _onFilterChanged(String f, String? v) {
    setState(() {
      selectedFilters[f] = v;
      if (f == 'Customer_Code') {
        final vals = lastFetchedData
            .where((e) => e['Customer_Code']?.toString() == v)
            .map((e) => e['Site_ID']?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => siteMap[a]!.compareTo(siteMap[b]!));
        fieldValueMap['Site_ID'] = vals;
        if (!vals.contains(selectedFilters['Site_ID'])) {
          selectedFilters['Site_ID'] = null;
        }
      }
    });
  }

  Future<void> _showGSCodeDialog() async {
    final filteredCodes = lastFetchedData
        .where((e) => selectedFilters.entries
        .where((kv) => kv.key != 'GS_Code')
        .every((kv) => e[kv.key]?.toString() == kv.value))
        .map((e) => e['GS_Code']?.toString() ?? '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) {
        final na = lastFetchedData.firstWhere((e) => e['GS_Code'] == a)['GS_Name'].toString();
        final nb = lastFetchedData.firstWhere((e) => e['GS_Code'] == b)['GS_Name'].toString();
        return na.compareTo(nb);
      });

    final tmp = selectedFilters['GS_Code']?.split(',').toSet() ?? {};

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, sd) => AlertDialog(
          title: const Text('Select Emp Name'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => sd(() => tmp.addAll(filteredCodes)), child: const Text('Select All')),
                    TextButton(onPressed: () => sd(() => tmp.clear()), child: const Text('Unselect All')),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: filteredCodes.map((c) {
                      final name = lastFetchedData.firstWhere((e) => e['GS_Code'] == c)['GS_Name'].toString();
                      return CheckboxListTile(
                        value: tmp.contains(c),
                        title: Text('$name ($c)'),
                        onChanged: (on) => sd(() {
                          if (on == true) tmp.add(c); else tmp.remove(c);
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectedFilters['GS_Code'] = tmp.isEmpty ? null : tmp.join(',');
                });
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (dt != null) setState(() => _selectedDate = dt);
  }

  Future<void> _selectTime() async {
    final tt = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (tt != null) setState(() => _selectedTime = tt);
  }

  Future<void> scheduleVirtualTraining(int courseId, String courseName, String date, String time, String siteId, String siteName) async {
    try {
      final filtered = lastFetchedData.where((e) {
        return selectedFilters.entries.every((kv) {
          if (kv.value == null) return true;
          if (kv.key == 'GS_Code') {
            final lst = kv.value!.split(',');
            return lst.contains(e[kv.key]?.toString());
          }
          return e[kv.key]?.toString() == kv.value;
        });
      }).toList();

      final traineeNames = filtered.map((e) => e['GS_Name'].toString()).toSet().toList();
      if (traineeNames.isEmpty) {
        ApiConfig.showToastMessage('No trainees found.');
        return;
      }

      final token = await _preferenceManager.getToken();
      final resp = await _dio.post(
        '${AppConfig.baseUrl}${ApiConfig.scheduleVirtualTraining}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'trainee_name': traineeNames,
          'course_name': courseName,
          'date': date,
          'time': time,
          'course_id': courseId,
          'site_id': siteId,
          'site_name': siteName,
        },
      );

      final d = resp.data;
      if (d['status'] == 200) {
        final tid = d['trainer_id']?.toString();
        if (tid != null) await _preferenceManager.saveTrainerId(tid);
        ApiConfig.showToastMessage(d['message'] ?? 'Scheduled.');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleTrainingsVirtual()));
      } else if (d['status'] == 409) {
        ApiConfig.showToastMessage(d['message'] ?? 'Already scheduled.');
      } else {
        ApiConfig.showToastMessage('Scheduling failed.');
      }
    } catch (_) {
      ApiConfig.showToastMessage('Error scheduling training.');
    }
  }

  bool get _canShowEmpName {
    return ['Company', 'Branch_Code', 'Customer_Code', 'Site_ID'].every((f) => selectedFilters[f] != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Training')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var f in searchableFields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: f == 'GS_Code'
                      ? ListTile(
                    title: const Text('Emp Name'),
                    subtitle: Text(
                      selectedFilters['GS_Code'] != null
                          ? selectedFilters['GS_Code']!.split(',').map((c) {
                        final e = lastFetchedData.firstWhere((e) => e['GS_Code']?.toString() == c, orElse: () => {});
                        return '${e['GS_Name']} ($c)';
                      }).join(', ')
                          : 'Select Emp Name',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    enabled: _canShowEmpName,
                    onTap: _canShowEmpName
                        ? _showGSCodeDialog
                        : () => ApiConfig.showToastMessage('Select Company, Branch, Customer & Site first'),
                  )
                      : DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: f == 'Branch_Code'
                          ? 'Branch Name'
                          : f == 'Customer_Code'
                          ? 'Customer Name'
                          : f == 'Site_ID'
                          ? 'Site Name'
                          : f,
                    ),
                    value: selectedFilters[f],
                    items: fieldValueMap[f]!
                        .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        _labelForField(f, v),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    onChanged: (v) => _onFilterChanged(f, v),
                  ),
                ),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Select Course'),
                value: selectedCourse,
                items: courseList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedCourse = v),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectDate,
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text('Select Date', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectTime,
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text('Select Time', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    if (_selectedDate == null || _selectedTime == null) {
                      ApiConfig.showToastMessage('Select date & time.');
                      return;
                    }
                    if (selectedCourse == null) {
                      ApiConfig.showToastMessage('Select course.');
                      return;
                    }
                    final sid = selectedFilters['Site_ID'];
                    final sname = sid != null ? siteMap[sid] ?? '' : '';
                    if (sid == null || sname.isEmpty) {
                      ApiConfig.showToastMessage('Select site.');
                      return;
                    }
                    final d = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
                    final t = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
                    final cid = int.tryParse(_courseMap.firstWhere((e) => e['name'] == selectedCourse)['id']!) ?? 0;
                    if (cid == 0) {
                      ApiConfig.showToastMessage('Invalid course.');
                      return;
                    }
                    await scheduleVirtualTraining(cid, selectedCourse!, d, t, sid, sname);
                  },
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.purple),
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
