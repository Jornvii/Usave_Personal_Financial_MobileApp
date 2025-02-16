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

          // ElevatedButton(
          //   style: ButtonStyle(
          //     backgroundColor: WidgetStateProperty.all(Colors.red.shade300),
          //   ),
          //   onPressed: () async {
          //     try {
          //       final notificationService = TransactionsNotificationService();

          //       await notificationService.initNotification();

          //       await notificationService.testTransactionNotifications();
          //     } catch (e) {
          //       print("Error running notifications: $e");
          //     }
          //   },
          //   child: const Text('Run Notifications'),

          // Button to schedule a notification
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Colors.red.shade300,
              ),
            ),
            onPressed: () {
              LocalNotificationService().schaduleNotification(
                title: "iSAVE",
                body: "Hello! Don't forget your transactions today!",
                hour: 9,
                minute: 0,
              );
            },
            child: const Text("daliii Schedule Notification"),
          ),
          // Button to execute and schedule notifications
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Colors.blue.shade300,
              ),
            ),
            onPressed: () async {
              try {
                // Create an instance of TransactionsNotificationService
                final notificationService = TransactionsNotificationService();
                // Initialize the notification service
                await notificationService.initNotification();

                final service = TransactionsNotificationService();

                // Fetch new Transaction Notification
                String transactionBody =
                    await service.genNotificationTransaction();

                // Fetch new Saving Goal Notification
                String savingGoalBody = await service.gNotificationSavingGoal();

                // String finalNotificationBody;
                // if (transactionBody == savingGoalBody) {
                //   finalNotificationBody =  "No transaction updates. Do you have any transaction today?";
                // } else {
                //   finalNotificationBody =
                //       "No transaction updates. Do you have any transaction today?";
                // }

                // Execute and schedule notifications
                await notificationService.executeAndScheduleNotifications(
                  id: 1,
                  title: "Transaction Reminder",
                  body: transactionBody,
                  hour: 6,
                  minute: 37,
                );
                // Execute and schedule notifications
                await notificationService.executeAndScheduleNotifications(
                  id: 2,
                  title: "Saving Goal Reminder",
                  body: savingGoalBody,
                  hour: 6,
                  minute: 38,
                );

                // Success feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Notifications scheduled successfully!")),
                );
              } catch (e) {
                // Handle errors and show feedback
                print("Error executing notifications: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Execute and Schedule Notifications"),
          ),
        ],
      )),
    );
  }
}
