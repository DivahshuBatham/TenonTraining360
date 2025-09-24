import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ScheduleTrainingsPhysical.dart';
import 'ScheduleTrainingsVirtual.dart';

class GuardTrainingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guard Training'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _cardButton(
                context, // ✅ pass context here
                Icons.group,
                'OnSite Training',
                Colors.blue,
                ScheduleTrainingsPhysical(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _cardButton(
                context, // ✅ pass context here
                Icons.calendar_today,
                'Virtual Training',
                Colors.green,
                ScheduleTrainingsVirtual(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardButton(
      BuildContext context, IconData icon, String label, Color color, Widget page) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
