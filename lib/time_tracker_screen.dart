// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:tenon_training_app/trainee/VideoTrainingTrainer.dart';
//
// import 'model/TrainingData.dart';
// import 'model/trainee_response.dart';
// import 'networking/api_config.dart';
//
// class TimeTrackerScreen extends StatefulWidget {
//   @override
//   _TimeTrackerScreenState createState() => _TimeTrackerScreenState();
// }
//
// class _TimeTrackerScreenState extends State<TimeTrackerScreen> {
//   List<TrainingData> trainees = [];
//   String? checkInTime;
//   // String? checkOutTime;
//
//   @override
//   void initState() {
//     super.initState();
//     loadTimes();
//     getData();
//   }
//
//   Future<void> getData() async {
//     try {
//       Dio dio = Dio();
//       final String url = '${ApiConfig.baseUrl}${ApiConfig.trainee}';
//       Response response = await dio.get(url);
//
//       List<TrainerResponse> fetchedTrainees = (response.data['data'] as List<dynamic>?)
//           ?.map((traineeData) => TrainerResponse.fromJson(traineeData))
//           .toList() ??
//           [];
//
//       setState(() {
//         // trainees = fetchedTrainees;
//         // isLoading = false;
//       });
//     } catch (e) {
//       ApiConfig.showToastMessage('Error: ${e.toString()}');
//       setState(() {
//         // isLoading = false;
//       });
//     }
//   }
//
//
//
//   Future<void> loadTimes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       checkInTime = prefs.getString('checkIn');
//       // checkOutTime = prefs.getString('checkOut');
//     });
//   }
//
//   Future<void> checkIn() async {
//     String now = DateFormat('hh:mm a').format(DateTime.now());
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('checkIn', now);
//     setState(() {
//       checkInTime = now;
//       // checkOutTime = null;
//     });
//
//
//     await Future.delayed(Duration(seconds: 1));
//     // Navigate to the AfterCheckInScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TraineeDetailScreen(trainees:trainees),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         // appBar: AppBar(title: Text('Check In/Out Tracker')),
//         body: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               SizedBox(height: 30),
//               Center(child: Text('Check-In Time: ${checkInTime ?? "Not yet"}')),
//               // Text('Check-Out Time: ${checkOutTime ?? "Not yet"}'),
//               // SizedBox(height: 30),
//               Center(
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: checkIn,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple
//                     ),
//                     child: Text('Check In',style: TextStyle(color: Colors.white),),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//               // ElevatedButton(
//               //   onPressed: checkOut,
//               //   child: Text('Check Out'),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
