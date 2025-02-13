import 'package:flutter/material.dart';

import '../provider/local_notification_service.dart';
import '../provider/notification_tractions.dart';

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
                LocalNotificationService().showNotification(
                  title: "iSAVE",
                  body: "Hello Do you have any transaction today?",
                );
              },
              child: const Text("show notification")),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red.shade300),
              ),
              onPressed: () {
                LocalNotificationService().schaduleNotification(
                  title: "iSAVE",
                  body: "Hello today pek ot?",
                  hour: 09,
                  minute: 00,
                );
              },
              child: const Text("show Notification by schedule")),

// Button to Trigger Notifications
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red.shade300),
            ),
            onPressed: () async {
              final service = TransactionsNotificationService();

              // Fetch new Transaction Notification
              String transactionBody =
                  await service.genNotificationTransaction();

              // Fetch new Saving Goal Notification
              String savingGoalBody = await service.gNotificationSavingGoal();

              // Schedule Transaction Notification
              service.transactionschaduleNotification(
                id: 1,
                title: "iSAVE - Transaction Summary",
                body: transactionBody,
                hour: 7,
                minute: 05,
              );

              // Schedule Saving Goal Notification
              service.transactionschaduleNotification(
                id: 2,
                title: "iSAVE - Saving Goal Update",
                body: savingGoalBody,
                hour: 7,
                minute: 15,
              );
            },
            child: const Text("Show Notifications"),
          ),
        ],
      )),
    );
  }
}
