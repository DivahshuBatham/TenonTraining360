import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../assessment_by_trainee/TraineeAssessment.dart';
import 'VirtualTrainingByTrainee.dart';

class VirtualPdfViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const VirtualPdfViewerScreen({super.key, required this.pdfUrl});

  @override
  State<VirtualPdfViewerScreen> createState() => _VirtualPdfViewerScreenState();
}

class _VirtualPdfViewerScreenState extends State<VirtualPdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    debugPrint('PDF URL: ${widget.pdfUrl}');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Go back to VideoTrainingByTrainee
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Training Material',style:TextStyle(color:Colors.white)),
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color:Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VirtualTrainingByTrainee() ,
                ),
              );
              // Navigator.pop(context); // Manual back
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SfPdfViewer.network(
                widget.pdfUrl,
                key: _pdfViewerKey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TraineeAssessment(),
                      ),
                    );
                  },
                  child: Text('Ready for Assessment',style:TextStyle(color:Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
