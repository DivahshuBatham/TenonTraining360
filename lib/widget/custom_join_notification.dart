import 'package:flutter/material.dart';
import '../trainee/VideoTrainingByTrainee.dart';
import 'custom_button.dart';

class CustomJoinNotification extends StatefulWidget {
  const CustomJoinNotification({Key? key}) : super(key: key);

  @override
  State<CustomJoinNotification> createState() => _CustomJoinNotificationState();
}

class _CustomJoinNotificationState extends State<CustomJoinNotification> {
  bool follow = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage("assets/download.jpg"), // fixed path
        ),
        const SizedBox(width: 15),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Dean Winchester",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.blueAccent),
            ),
            const SizedBox(height: 5),
            Text(
              "Now following you • 1h",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.blueGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Expanded(
          child: CustomButton(
            height: 40,
            color: Colors.blue,
            textColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoTrainingByTrainee()));

            },
            text: "Join",
          ),
        ),

      ],
    );
  }
}
