import 'package:flutter/material.dart';
import 'package:tenon_training_app/assessment_by_trainee/TraineeAssessment.dart';

class PhysicalTrainingComplete extends StatefulWidget {
  const PhysicalTrainingComplete({super.key});

  @override
  State<PhysicalTrainingComplete> createState() => _TrainingCompleteState();
}

class _TrainingCompleteState extends State<PhysicalTrainingComplete> {
  bool isAssessmentEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training Complete"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isAssessmentEnabled
                  ? null
                  : () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text(
                        "Are you sure"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          setState(() {
                            isAssessmentEnabled = true;
                          });
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Physical Training Completed",style: TextStyle(color:Colors.white),),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isAssessmentEnabled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TraineeAssessment(),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Ready to Assessment",style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
