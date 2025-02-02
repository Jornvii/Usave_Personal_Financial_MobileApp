import 'package:flutter/material.dart';

import '../../provider/notification_service.dart';

class TestNotificatioScreen extends StatefulWidget {
  const TestNotificatioScreen({super.key});

  @override
  State<TestNotificatioScreen> createState() => _TestNotificatioScreenState();
}

class _TestNotificatioScreenState extends State<TestNotificatioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Home Screen'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green.shade300),
              ),
              onPressed: () {
                // show notification
                NotificationService().showNotification(
                  title: "iSAVE",
                  body: "Hello this is test notification",
                );
              },
              child: const Text("show notification")),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red.shade300),
              ),
              onPressed: () {
                NotificationService().schaduleNotification(
                  title: "iSAVE",
                  body: "Hello today pek ot?",
                  hour: 09,
                  minute: 00,
                );
              },
              child: const Text("show Notification by schedule")),
        ],
      )),
    );
  }
  
}
