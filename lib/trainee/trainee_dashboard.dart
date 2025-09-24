import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dio/dio.dart';
import '../NotificationScreen.dart';
import '../environment/Environment.dart';
import '../login.dart';
import '../networking/api_config.dart';
import '../shared_preference/shared_preference_manager.dart';
import '../utils/ApiClient.dart';
import 'GuardTrainingByTrainee.dart';
import 'PhysicalTrainingByTrainee.dart';
import 'VirtualTrainingByTrainee.dart';

class _ChartData {
  final String month;
  final double percentile;
  _ChartData(this.month, this.percentile);
}

class _StackedChartData {
  final String month;
  final double completedVirtual, pendingVirtual, completedPhysical, pendingPhysical;
  _StackedChartData(this.month, this.completedVirtual, this.pendingVirtual, this.completedPhysical, this.pendingPhysical);
}

class _DonutData {
  final String label;
  final double count;
  final Color color;
  _DonutData(this.label, this.count, this.color);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class TraineeDashboard extends StatefulWidget {
  @override
  _TraineeDashboardState createState() => _TraineeDashboardState();
}

class _TraineeDashboardState extends State<TraineeDashboard> {
  final SharedPreferenceManager _prefs = SharedPreferenceManager();
  File? _profileImage;
  String name = '', email = '', token = '';
  int _notificationCount = 0;
  bool _showDashboard = true;

  final List<_DonutData> _donutData = [
    _DonutData('Completed', 70, Colors.green),
    _DonutData('Pending', 20, Colors.orange),
    _DonutData('Missed', 10, Colors.red),
  ];
  String _donutCenterText = '';

  @override
  void initState() {
    super.initState();
    _initialize();
    final total = _donutData.fold(0.0, (sum, d) => sum + d.count);
    _donutCenterText = 'Total\n${total.toInt()}';
  }

  Future<void> _initialize() async {
    token = await _prefs.getToken() ?? '';
    // name = await _prefs.getName() ?? '';
    // email = await _prefs.getEmail() ?? '';
    final path = await _prefs.getProfileImagePath();
    if (path != null && File(path).existsSync()) {
      _profileImage = File(path);
    }

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (_) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
      },
    );

    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null && n.android != null) {
        setState(() => _notificationCount++);
        flutterLocalNotificationsPlugin.show(
          n.hashCode,
          n.title,
          n.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default Notifications',
              channelDescription: 'General notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg?.notification != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Trainee Dashboard"),
          actions: [_notificationIcon()],
        ),
        drawer: _buildDrawer(),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    _showDashboard ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _showDashboard = !_showDashboard;
                    });
                  },
                ),
              ),
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                crossFadeState: _showDashboard
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  children: [
                    SizedBox(height: 10),
                    _buildCourseSummary(),
                    SizedBox(height: 20),
                    _buildDoughnutChart(),
                    SizedBox(height: 20),
                    _buildPercentileChart(),
                    SizedBox(height: 20),
                    _buildAttendanceChart(),
                    SizedBox(height: 20),
                  ],
                ),
                secondChild: SizedBox.shrink(),
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: _buildCard(Icons.person, "Virtual Training", Colors.blue, () {
              //         Navigator.push(context, MaterialPageRoute(builder: (_) => VirtualTrainingByTrainee()));
              //       }),
              //     ),
              //     SizedBox(width: 16),
              //     Expanded(
              //       child: _buildCard(Icons.assessment, "Onsite Training", Colors.green, () {
              //         Navigator.push(context, MaterialPageRoute(builder: (_) => PhysicalTrainingByTrainee()));
              //       }),
              //     ),
              //   ],
              // ),

              Row(
                children: [
                  Expanded(
                    child: _buildCard(Icons.person, "Guard Training", Colors.blue, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GuardTrainingByTrainee()));
                    }),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCard(Icons.assessment, "Corporate Training", Colors.green, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PhysicalTrainingByTrainee()));
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationIcon() => Stack(
    children: [
      IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {
          setState(() => _notificationCount = 0);
          // Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
        },
      ),
      if (_notificationCount > 0)
        Positioned(
          right: 5,
          top: 5,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            constraints: BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text('$_notificationCount', style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
          ),
        ),
    ],
  );

  Widget _buildDrawer() => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 16),
          color: Colors.purple,
          child: Column(children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : AssetImage('assets/download.jpg') as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(name.isNotEmpty ? name : 'User Name', style: TextStyle(color: Colors.white, fontSize: 20)),
            Text(email, style: TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
        ),
        ListTile(leading: Icon(Icons.home), title: Text("Home"), onTap: () => Navigator.pop(context)),
        ListTile(leading: Icon(Icons.favorite), title: Text("Favorite")),
        ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
        ListTile(leading: Icon(Icons.logout), title: Text("Logout"), onTap: () => _showLogoutDialog(context)),
      ],
    ),
  );

  // ------------------- LOGOUT DIALOG -------------------
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Choose logout option:"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              userLogout(context); // Current device logout
            },
            child: Text("Current Device"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              logoutAllDevices(context);
              // Optionally implement API call here for all devices
            },
            child: Text("All Devices"),
          ),
        ],
      ),
    );
  }

  // ------------------- USER LOGOUT WITH CRASHLYTICS -------------------
  Future<void> userLogout(BuildContext context) async {
    final token = await _prefs.getToken();

    // If token is null or empty, clear everything and go to login
    if (token == null || token.isEmpty) {
      await _prefs.clearToken();
      await _prefs.removeRole();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
      return;
    }

    final dio = ApiClient.dio;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      final resp = await dio.post(
        ApiConfig.userLogout,
        options: Options(validateStatus: (_) => true),
      );

      if (resp.statusCode == 200) {
        await _prefs.clearToken();
        await _prefs.removeRole();
        ApiConfig.showToastMessage(resp.data['message'] ?? "Logged out successfully");

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Login()),
          );
        }
      }
      // Handle 401 Unauthorized explicitly
      else if (resp.statusCode == 401) {
        await _prefs.clearToken();
        await _prefs.removeRole();
        ApiConfig.showToastMessage("Session expired. Please login again.");
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Login()),
          );
        }
      }
      else {
        // Other errors
        ApiConfig.showToastMessage(
          resp.data?['message'] ?? "Failed to logout. Try again.",
        );
      }
    } catch (e) {
      // Catch any other network / exception
      await _prefs.clearToken();
      await _prefs.removeRole();
      ApiConfig.showToastMessage("Error during logout. Please login again.");
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    }
  }


  Future<void> logoutAllDevices(BuildContext context) async {
    final token = await _prefs.getToken();

    if (token == null || token.isEmpty) {
      await _prefs.clearToken();
      await _prefs.removeRole(); // 👈 clear role here too
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
      return;
    }

    final dio = ApiClient.dio;
    dio.options.headers["Authorization"] = "Bearer $token";

    FirebaseCrashlytics.instance.setCustomKey("last_api_called", "logoutAllDevices");

    try {
      final resp = await dio.post(
        ApiConfig.userLogoutAllDevice,
        options: Options(validateStatus: (_) => true),
      );

      FirebaseCrashlytics.instance
          .setCustomKey("last_status_code", resp.statusCode ?? 0);

      if (resp.statusCode == 200 && resp.data['status'] == true) {
        // Clear token + role locally
        await _prefs.clearToken();
        await _prefs.removeRole(); // 👈 added
        ApiConfig.showToastMessage(
            resp.data['message'] ?? "Logged out from all devices");

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Login()),
          );
        }
      } else if (resp.statusCode == 401) {
        await _prefs.clearToken();
        await _prefs.removeRole(); // 👈 added
        ApiConfig.showToastMessage("Session expired. Please login again.");

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Login()),
          );
        }
      } else {
        ApiConfig.showToastMessage(
            resp.data['message'] ?? "Logout failed. Try again.");
        FirebaseCrashlytics.instance.recordError(
          Exception("LogoutAll failed with status ${resp.statusCode}"),
          StackTrace.current,
          reason: "Non-fatal logoutAll failure",
        );
      }
    } catch (e, s) {
      await _prefs.clearToken();
      await _prefs.removeRole(); // 👈 also in catch
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "Unexpected error during logoutAll",
      );
      ApiConfig.showToastMessage("An error occurred during logout from all devices.");
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    }
  }

  Widget _buildCourseSummary() => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 4,
    child: Container(
      height: 100,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _summaryItem("Courses Attended", "12", Colors.purple),
          VerticalDivider(color: Colors.grey.shade400),
          _summaryItem("Average Score", "86", Colors.teal),
        ],
      ),
    ),
  );

  Widget _summaryItem(String title, String value, Color color) => Expanded(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 24, color: color)),
    ]),
  );

  Widget _buildCard(IconData icon, String label, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 16)),
        ]),
      ),
    ),
  );

  Widget _buildDoughnutChart() {
    final sections = _donutData.asMap().entries.map((entry) {
      final d = entry.value;
      final isSelected = (_donutCenterText == '${d.label}\n${d.count.toInt()}');
      return PieChartSectionData(
        value: d.count,
        color: d.color,
        radius: isSelected ? 60 : 50,
        showTitle: false,
      );
    }).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: Column(
            children: [
              Text('Course Completion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 4,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, resp) {
                            if (resp?.touchedSection != null) {
                              final idx = resp!.touchedSection!.touchedSectionIndex;
                              final tapped = _donutData[idx];
                              setState(() {
                                _donutCenterText = '${tapped.label}\n${tapped.count.toInt()}';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Text(
                      _donutCenterText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPercentileChart() {
    final data = [
      _ChartData('Jan', 65),
      _ChartData('Feb', 72),
      _ChartData('Mar', 80),
      _ChartData('Apr', 78),
      _ChartData('May', 85),
      _ChartData('Jun', 88),
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SfCartesianChart(
          title: ChartTitle(text: 'Monthly Percentile'),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(),
          series: <LineSeries<_ChartData, String>>[
            LineSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.month,
              yValueMapper: (d, _) => d.percentile,
              markerSettings: MarkerSettings(isVisible: true),
              dataLabelSettings: DataLabelSettings(isVisible: true),
              color: Colors.deepPurple,
              width: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    final data = [
      _StackedChartData('Jan', 8, 2, 5, 5),
      _StackedChartData('Feb', 10, 0, 6, 4),
      _StackedChartData('Mar', 7, 3, 8, 2),
      _StackedChartData('Apr', 9, 1, 7, 3),
      _StackedChartData('May', 11, 0, 9, 1),
      _StackedChartData('Jun', 12, 0, 10, 0),
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SfCartesianChart(
          title: ChartTitle(text: 'Attendance by Course'),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'Sessions')),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            StackedColumnSeries<_StackedChartData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.month,
              yValueMapper: (d, _) => d.completedVirtual,
              name: 'Completed Virtual',
              color: Colors.lightBlueAccent,
            ),
            StackedColumnSeries<_StackedChartData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.month,
              yValueMapper: (d, _) => d.pendingVirtual,
              name: 'Pending Virtual',
              color: Colors.lightBlueAccent,
            ),
            StackedColumnSeries<_StackedChartData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.month,
              yValueMapper: (d, _) => d.completedPhysical,
              name: 'Completed Physical',
              color: Colors.lightBlueAccent,
            ),
            StackedColumnSeries<_StackedChartData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.month,
              yValueMapper: (d, _) => d.pendingPhysical,
              name: 'Pending Physical',
              color: Colors.lightBlueAccent,
            ),
          ],
        ),
      ),
    );
  }

}
