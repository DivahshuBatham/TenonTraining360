import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'PhysicalTrainingComplete.dart';

class PhysicalPdfViewerScreen extends StatefulWidget {
  const PhysicalPdfViewerScreen({super.key});

  @override
  State<PhysicalPdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PhysicalPdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final String data = ModalRoute.of(context)!.settings.arguments as String;
    debugPrint('PDF URL: $data');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Go back to VideoTrainingByTrainee
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: const Text('Training Materials',style:TextStyle(color:Colors.white)),
          )),
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.bookmark),
          //     onPressed: () {
          //       _pdfViewerKey.currentState?.openBookmarkView();
          //     },
          //   ),
          // ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SfPdfViewer.network(
                data,
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
                      MaterialPageRoute(builder: (context) => PhysicalTrainingComplete()),
                    );
                  },
                  child: const Text('Confirm & Continue',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
