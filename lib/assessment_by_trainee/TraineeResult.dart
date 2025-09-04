import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../environment/Environment.dart';
import '../networking/api_config.dart';
import '../shared_preference/shared_preference_manager.dart';
import '../trainee/trainee_dashboard.dart';

class TraineeResult extends StatefulWidget {
  const TraineeResult({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  final int score;
  final int totalQuestions;

  @override
  State<TraineeResult> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<TraineeResult> {
  late int percentage;
  String checkoutTime = DateFormat.jm().format(DateTime.now());

  bool isExitSuccessfully = false;
  String? trainingID;
  String? traineeID;

  final sharedPreferenceManager = SharedPreferenceManager();

  @override
  void initState() {
    super.initState();
    loadTrainingID();
    percentage = (widget.score / widget.totalQuestions * 100).round();
  }


  void loadTrainingID() async {
    trainingID = await sharedPreferenceManager.getPhysicalTrainingID();
    traineeID = await sharedPreferenceManager.getTraineeID();
    setState(() {}); // To update the UI if needed
  }

  Future<void> updateAssessmentStatus(String trainingId,String trainingType,String traineeId,bool isExitSuccessfully) async{

    try{
      final String url = '${AppConfig.baseUrl}''${ApiConfig.updateTraineeStatus}';
      final dio = Dio();

      final response = await dio.patch(url,data: {
        'training_id':trainingId,
        'training_type':trainingType,
        'trainee_id':traineeId,
        'is_exit':isExitSuccessfully
      });

      final responseData = response.data;


      if(responseData['status']==true){

        ApiConfig.showToastMessage(responseData['message']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TraineeDashboard()),
        );
      }

    }catch(e){

      ApiConfig.showToastMessage(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'Your Score:',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    value: widget.score / widget.totalQuestions,
                    color: Colors.green,
                    backgroundColor: Colors.white,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${widget.score}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical:1),
                    ),
                    Text(
                      '${widget.totalQuestions}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   '$percentage%',
                    //   style: const TextStyle(fontSize: 40,fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:(){
                      isExitSuccessfully = true;
                      updateAssessmentStatus(trainingID!,'physical',traineeID!, isExitSuccessfully);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
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
