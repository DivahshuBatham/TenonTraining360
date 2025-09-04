import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:tenon_training_app/login.dart';
import 'package:tenon_training_app/shared_preference/shared_preference_manager.dart';
import '../course/CreateCourse.dart';
import '../environment/Environment.dart';
import '../networking/api_config.dart';
import 'ScheduleTrainingsVirtual.dart';
import 'ScheduleTrainingsPhysical.dart';

class TrainerDashboard extends StatefulWidget {
  @override
  State<TrainerDashboard> createState() => TrainerDashboardState();
}

class TrainerDashboardState extends State<TrainerDashboard> {
  final SharedPreferenceManager _pref = SharedPreferenceManager();

  File? _profileImage;
  bool _showTrainingButtons = false;
  bool showDashboard = true;
  String selectedTrainingType = 'All';
  int touchedIndex = -1;

  final allBranchPerformance = [
    _BranchPerformance('PGP-HYDE', 80, 'Physical'),
    _BranchPerformance('PGP-DNCR', 65, 'Virtual'),
    _BranchPerformance('TPS-PANI', 90, 'Physical'),
    _BranchPerformance('PGP-MUMB', 75, 'Virtual'),
  ];
  final allCourseAttendance = [
    _CourseAttendance('Handle By PPE', 120, 'Physical'),
    _CourseAttendance('Y', 90, 'Virtual'),
    _CourseAttendance('Z', 110, 'Physical'),
    _CourseAttendance('A', 70, 'Virtual'),
  ];
  final allFormatData = [
    _FormatData('Completed', 120, Colors.green, 'Physical'),
    _FormatData('Failed', 30, Colors.red, 'Physical'),
    // _FormatData('Pending', 50, Colors.orange, 'Physical'),
    _FormatData('Pending', 50, Colors.orange, 'Virtual'),
    // _FormatData('Completed', 80, Colors.green, 'Virtual'),
    // _FormatData('Failed', 20, Colors.red, 'Virtual'),
  ];

  double get averageRating => 4.5;
  List<_FormatData> get formatData =>
      selectedTrainingType == 'All'
          ? allFormatData
          : allFormatData.where((e) => e.type == selectedTrainingType).toList();
  List<_BranchPerformance> get branchPerformance =>
      selectedTrainingType == 'All'
          ? allBranchPerformance
          : allBranchPerformance.where((e) => e.type == selectedTrainingType).toList();
  List<_CourseAttendance> get courseAttendance =>
      selectedTrainingType == 'All'
          ? allCourseAttendance
          : allCourseAttendance.where((e) => e.type == selectedTrainingType).toList();
  double get totalCount => formatData.fold(0, (sum, d) => sum + d.count);
  double get averageScore {
    if (courseAttendance.isEmpty) return 0;
    double total = courseAttendance.fold(0, (sum, e) => sum + e.attendance);
    return total / courseAttendance.length;
  }

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final img = await _pref.getProfileImagePath();
    if (img != null && File(img).existsSync()) {
      _profileImage = File(img);
    }
    setState(() => _showTrainingButtons = true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Trainer Dashboard")),
        drawer: _buildDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(showDashboard
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    iconSize: 30,
                    tooltip:
                    showDashboard ? 'Hide Dashboard' : 'Show Dashboard',
                    onPressed: () =>
                        setState(() => showDashboard = !showDashboard),
                  ),
                ),
                SizedBox(height: 16),
                if (showDashboard) ...[
                  _buildFilterChips(),
                  SizedBox(height: 16),
                  _summaryCard(),
                  SizedBox(height: 8),
                  _wrapCard('Course Completion', _flPieChart()),
                  _wrapRatingCard('Average Rating', _startingRatingCard()),
                  _wrapCard('Attendance by Course', _attendanceChart()),
                  _wrapCard('Performance by Branch', _branchChart()),
                  SizedBox(height: 16),
                ],
                if (_showTrainingButtons)
                  Row(
                    children: [
                      Expanded(
                          child: _cardButton(Icons.group, 'OnSite Training',
                              Colors.blue, ScheduleTrainingsPhysical())),
                      SizedBox(width: 16),
                      Expanded(
                          child: _cardButton(Icons.calendar_today,
                              'Virtual Training', Colors.green,
                              ScheduleTrainingsVirtual())),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _startingRatingCard() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StarRatingWidget(
              rating: averageRating,
              size: 32,
              color: Colors.amber,
            ),
            SizedBox(height: 4),
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Text(
            //   'Average Rating',
            //   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: ['All', 'Physical', 'Virtual']
        .map((type) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(type),
        selected: selectedTrainingType == type,
        onSelected: (_) =>
            setState(() => selectedTrainingType = type),
      ),
    ))
        .toList(),
  );

  Widget _summaryCard() {
    final totalCourses = courseAttendance.length;
    final avg = averageScore.toStringAsFixed(1);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryTile('Courses Attended', '$totalCourses',
                Colors.blue),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildSummaryTile('Average Score', avg, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value, Color color) =>
      Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, color: color)),
        ],
      );

  Widget _wrapCard(String title, Widget child) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    margin: EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          SizedBox(height: 200, child: child),
        ],
      ),
    ),
  );

  Widget _wrapRatingCard(String title, Widget child) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    margin: EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          SizedBox(height: 80, child: child),
        ],
      ),
    ),
  );

  charts.SfCartesianChart _branchChart() => charts.SfCartesianChart(
    primaryXAxis: charts.CategoryAxis(),
    tooltipBehavior: charts.TooltipBehavior(enable: true),
    series: [
      charts.ColumnSeries<_BranchPerformance, String>(
        dataSource: branchPerformance,
        xValueMapper: (d, _) => d.branch,
        yValueMapper: (d, _) => d.performance,
        color: Colors.blue,
      ),
    ],
  );

  charts.SfCartesianChart _attendanceChart() => charts.SfCartesianChart(
    primaryXAxis: charts.CategoryAxis(),
    tooltipBehavior: charts.TooltipBehavior(enable: true),
    series: [
      charts.ColumnSeries<_CourseAttendance, String>(
        dataSource: courseAttendance,
        xValueMapper: (d, _) => d.course,
        yValueMapper: (d, _) => d.attendance,
        color: Colors.blueAccent,
      ),
    ],
  );

  Widget _flPieChart() => Column(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(height: 40),
      SizedBox(

        height: 100,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            pieTouchData: PieTouchData(touchCallback: (evt, resp) {
              setState(() {
                touchedIndex = (evt.isInterestedForInteractions &&
                    resp?.touchedSection != null)
                    ? resp!.touchedSection!.touchedSectionIndex
                    : -1;
              });
            }),
            sections: List.generate(formatData.length, (i) {
              final d = formatData[i];
              final isTouched = i == touchedIndex;
              return PieChartSectionData(
                color: d.color,
                value: d.count,
                title: '${d.category}\n${d.count.toInt()}',
                radius: isTouched ? 70 : 60,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ),
        ),
      ),
      SizedBox(height: 20),

      // Text(
      //   'Total: ${totalCount.toInt()}',
      //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      // ),
    ],
  );
  Widget _cardButton(
      IconData icon, String label, Color color, Widget page) =>
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => page)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color),
                SizedBox(height: 8),
                Text(label),
              ],
            ),
          ),
        ),
      );

  Widget _buildDrawer() => Drawer(
    child: ListView(padding: EdgeInsets.zero, children: [
      Container(
        padding:
        EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 16),
        color: Colors.purple,
        child: Column(children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : AssetImage('assets/download.jpg') as ImageProvider,
          ),
          SizedBox(height: 10),
        ]),
      ),
      ListTile(leading: Icon(Icons.home), title: Text("Home"), onTap: () => Navigator.pop(context)),
      ListTile(leading: Icon(Icons.person), title: Text("Profile"), onTap: () {}),
      ListTile(leading: Icon(Icons.settings), title: Text("Create Course"), onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateCourse()));
      }),
      ListTile(leading: Icon(Icons.logout), title: Text("Logout"), onTap: () => userLogout(context)),
    ]),
  );

  Future<void> userLogout(BuildContext context) async {
    final token = await _pref.getToken();
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));
    try {
      final resp = await dio.post(ApiConfig.userLogout);
      if (resp.statusCode == 200) {
        await _pref.clearToken();
        ApiConfig.showToastMessage(resp.data['message']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
      } else {
        ApiConfig.showToastMessage('Logout failed. Try again.');
      }
    } catch (_) {
      ApiConfig.showToastMessage('An error occurred during logout.');
    }
  }
}

class _BranchPerformance {
  final String branch;
  final double performance;
  final String type;

  _BranchPerformance(this.branch, this.performance, this.type);
}

class _CourseAttendance {
  final String course;
  final double attendance;
  final String type;

  _CourseAttendance(this.course, this.attendance, this.type);
}

class _FormatData {
  final String category;
  final double count;
  final Color color;
  final String type;

  _FormatData(this.category, this.count, this.color, this.type);
}

// ☆ Star rating widget supporting full, half & empty stars
class StarRatingWidget extends StatelessWidget {
  final int starCount;
  final double rating;
  final Color? color;
  final double size;

  const StarRatingWidget({
    Key? key,
    this.starCount = 5,
    required this.rating,
    this.color,
    this.size = 24.0,
  }) : super(key: key);

  Widget _buildStar(int index) {
    if (index >= rating) {
      return Icon(
        Icons.star_border,
        size: size,
        color: (color ?? Colors.amber).withOpacity(0.3),
      );
    } else if (index > rating - 1 && index < rating) {
      return Icon(Icons.star_half, size: size, color: color ?? Colors.amber);
    } else {
      return Icon(Icons.star, size: size, color: color ?? Colors.amber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) => _buildStar(index)),
    );
  }
}
