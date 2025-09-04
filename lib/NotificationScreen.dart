import 'package:flutter/material.dart';

import 'widget/custom_join_notification.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
        body: Padding(
            padding:EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                  'New',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              CustomJoinNotification(),
            ]
            ,
          ),
        ),
      ),

    );
  }
}
