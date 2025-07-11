import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/notification_db.dart';
import '../../models/transaction_db.dart';
import '../models/saving_goaldb.dart';

class TransactionsNotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  final List<String> _messages = [];
  GenerativeModel? _model;
  final TransactionDB transactionDB = TransactionDB();
  final bool _initialized = false;
  bool get isInitialized => _initialized;
  TransactionsNotificationService() {
    _initializeChat();
  }
  void _initializeChat() async {
    const apiKey = 'AIzaSyDP9iwhVwLh0_32bdcoQI_obhsyJF9r5oE';
    if (apiKey.isEmpty) {
      stderr.writeln('No API key provided');
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash-thinking-exp-01-21',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 65536,
        responseMimeType: 'text/plain',
      ),
    );
  }

  // initialize the notification service
  Future<void> initNotification() async {
    if (_initialized) return;

//initialize the timezone
    tz.initializeTimeZones();
    final String cuurentTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(cuurentTimezone));

    // initialize for android
    const initSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    //init setting
    const initSettings = InitializationSettings(android: initSettingsAndroid);

//final init settings
    await notificationPlugin.initialize(initSettings);

// Notification Details
    NotificationDetails notificationDetails() {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      );
    }
  }

  // Format current time
  String _formatCurrentTime() {
    final DateFormat timeFormat = DateFormat.jm();
    return timeFormat.format(DateTime.now());
  }

  // Generate Transaction Notification
// Generate Transaction Notification
  Future<String> genNotificationTransaction() async {
    try {
      final transactions = await transactionDB.getTransactionsToday();

      // Exit if transactions are empty
      if (transactions.isEmpty) {
        return "No transaction yet. Do you have any transaction today?🤑";
      }

      // Retrieve last known transaction state
      final prefs = await SharedPreferences.getInstance();
      final String? lastTransactionData =
          prefs.getString('lastTransactionData');

      // Serialize current transaction data for comparison
      final currentTransactionData = transactions.toString();
      if (currentTransactionData == lastTransactionData) {
        return "No transaction updates. Do you have any transaction today?";
      }

      // Update shared preferences with current transaction data
      await prefs.setString('lastTransactionData', currentTransactionData);

      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      double totalSaving = 0.0;
      Map<String, double> categoryExpenses = {};

      for (var transaction in transactions) {
        final type = transaction['typeCategory'];
        final amount = transaction['amount'] as double;
        final category = transaction['category'] ?? "Uncategorized";

        if (type == 'Income') {
          totalIncome += amount;
        } else if (type == 'Expense') {
          totalExpenses += amount;
          categoryExpenses[category] =
              (categoryExpenses[category] ?? 0) + amount;
        } else if (type == 'Saving') {
          totalSaving += amount;
        }
      }

      double balance = totalIncome - totalExpenses;

      // Preserve the original prompt1 as per request
      String prompt1 = """
    Analyze my financial data and generate a short notification:
    - Total Income: \$${totalIncome.toStringAsFixed(2)}
    - Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
    - Total Saving: \$${totalSaving.toStringAsFixed(2)}
    - Balance: \$${balance.toStringAsFixed(2)}
    Key Expense Categories: ${categoryExpenses.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}

    Provide a concise alert based on the data or with a sentence alert me better financial like a quote or sth, (write all in just short paragraph)
    """;

      // Ensure AI model is initialized
      if (_model == null) {
        print("AI model not initialized.");
        return "AI model initialization failed.";
      }

      // Generate AI response
      final response = await _model!.generateContent([Content.text(prompt1)]);

      // Ensure response is valid
      final notificationText =
          response.text?.trim() ?? "Transaction update failed.";

      // Save notification to database
      final notificationDB = NotificationDB();
      await notificationDB.insertNotification({
        'message': notificationText,
        'time': _formatCurrentTime(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,

      });

      return notificationText;
    } catch (e) {
      print("Error generating transaction notification: $e");
      return "Transaction update failed.";
    }
  }

// Generate Saving Goal Notification
  Future<String> gNotificationSavingGoal() async {
    try {
      final savingGoalDB = SavingGoalDB();
      final savingGoals = await savingGoalDB.fetchSavingGoals();
      final transactions = await transactionDB.getTransactions();

      // Exit if savingGoals and transactions  empty
      if (savingGoals.isEmpty && transactions.isEmpty) {
        return "No Saving transaction yet. Do you have any transaction today?🐖";
      } else if (savingGoals.isEmpty) {
        return "No Saving Goals yet. Do you have any transaction today?🐖";
      } else if (transactions.isEmpty) {
        return "No Saving transaction yet. Do you have any transaction today?🐖";
      }

      // Retrieve last known saving goals and transaction state
      final prefs = await SharedPreferences.getInstance();
      final String? lastSavingGoalsData =
          prefs.getString('lastSavingGoalsData');
      final String? lastTransactionsData =
          prefs.getString('lastTransactionsData');

      // Serialize current saving goal and transaction data for comparison
      final currentSavingGoalsData = savingGoals.toString();
      final currentTransactionsData = transactions.toString();

      if (currentSavingGoalsData == lastSavingGoalsData &&
          currentTransactionsData == lastTransactionsData) {
        return "No saving transaction updates. Do you have any transaction today?";
      }

      // Update shared preferences with current data
      await prefs.setString('lastSavingGoalsData', currentSavingGoalsData);
      await prefs.setString('lastTransactionsData', currentTransactionsData);

      Map<String, double> savingsByCategory = {};

      for (var transaction in transactions) {
        final type = transaction['typeCategory'];
        final amount = transaction['amount'] as double;
        final category = transaction['category'] ?? "Uncategorized";

        if (type == 'Saving') {
          savingsByCategory[category] =
              (savingsByCategory[category] ?? 0) + amount;
        }
      }

      bool hasValidSavings = false;
      List<String> notificationsList = [];

      for (var goal in savingGoals) {
        final savingCategory = goal['savingCategory'] as String;
        final goalAmount = goal['goalAmount'] as double;
        final savedAmount = savingsByCategory[savingCategory] ?? 0.0;

        if (savedAmount > 0) {
          hasValidSavings = true;
          double percentComplete =
              ((savedAmount / goalAmount) * 100).clamp(0, 100);

          if (savedAmount >= goalAmount) {
            notificationsList.add(
                "🎉 Congrats! Goal reached for $savingCategory! Saved: \$${savedAmount.toStringAsFixed(2)} (Goal: \$${goalAmount.toStringAsFixed(2)}) - ${percentComplete.toStringAsFixed(1)}% complete.");
          } else {
            final remaining = goalAmount - savedAmount;
            notificationsList.add(
                "Keep going! Saved ${percentComplete.toStringAsFixed(1)}% for $savingCategory. \$${remaining.toStringAsFixed(2)} left.");
          }
        }
      }

      if (hasValidSavings) {
        String notificationText = notificationsList.join("\n");
        String time = _formatCurrentTime();
        int timestamp = DateTime.now().millisecondsSinceEpoch;

        final notificationDB = NotificationDB();
        await notificationDB.insertNotification({
          'message': notificationText,
          'time': time,
          'timestamp': timestamp,
        });

        return notificationText;
      }

      return "No saving updates.";
    } catch (e) {
      print("Error generating saving goal notification: $e");
      return "Saving goal update failed.";
    }
  }

  // schacule Notification for local notification
  Future<void> transactionschaduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("Notification Scheduled: $title at $hour:$minute");
  }

// fucntion  for  wokring (schacule Notification  local notification and genNotificationTransaction)

  Future<void> executeTransactionNotifications({
    required int id,
    required String title,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    int scheduledHour = 12;
    int scheduledMinute = 0;



    // final notificationdb = NotificationDB();
    // List<Map<String, dynamic>> notificationstoday =
    //     await notificationdb.getTodaysNotifications();

    // // if (notificationstoday.isEmpty) {
      try {
        // Generate notification messages
        String transactionNotification = await genNotificationTransaction();

        print("Transaction Notification: $transactionNotification");

        // Schedule notification at the set time
        var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            now.day, scheduledHour, scheduledMinute);

        // Schedule the notification
        await notificationPlugin.zonedSchedule(
          id,
          title,
          transactionNotification,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'Financial Updates',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              enableLights: true,
              styleInformation: BigTextStyleInformation(''),
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        );

        print(
            "Notification Scheduled: Financial Update at $scheduledHour:$scheduledMinute daily.");
      } catch (e) {
        print("Error executing and scheduling notifications: $e");
      }
   
  }

  // fucntion  for  wokring (schacule Notification  local notification and gNotificationSavingGoal)
  Future<void> executeSavingNotifications({
    required int id,
    required String title,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    int scheduledHour = 20;
    int scheduledMinute = 0;



    final notificationdb = NotificationDB();

    // Fetch today's notifications from the database
    List<Map<String, dynamic>> notificationstoday =
        await notificationdb.getTodaysNotifications();

    // Only proceed if there are no notifications for today and it's past the scheduled time
    if (notificationstoday.isEmpty) {
      try {
        // Generate notification messages
        String transactionNotification = await gNotificationSavingGoal();

        print("Transaction Notification: $transactionNotification");

        // Schedule notification at the set time
        var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            now.day, scheduledHour, scheduledMinute);

        // Schedule the notification
        await notificationPlugin.zonedSchedule(
          id,
          title,
          transactionNotification,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'Financial Updates',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              enableLights: true,
              styleInformation: BigTextStyleInformation(''),
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        );

        print(
            "Notification Scheduled: Financial Update at $scheduledHour:$scheduledMinute daily.");
      } catch (e) {
        print("Error executing and scheduling notifications: $e");
      }
    } else {
      print(
          "No notifications for today or it's not yet time. Skipping scheduling.");
    }
  }

// testttttttttttttttttttttttttttt (schacule Notification  local notification and genNotificationTransaction and gNotificationSavingGoal )
  Future<void> testTransactionNotifications() async {
    try {
      // Generate transaction notification
      String transactionNotification = await genNotificationTransaction();
      print("Transaction Notification: $transactionNotification");

      // Generate saving goal notification
      String savingGoalNotification = await gNotificationSavingGoal();
      print("Saving Goal Notification: $savingGoalNotification");

      // Check if messages are the same
      String finalNotificationBody;
      if (transactionNotification == savingGoalNotification) {
        finalNotificationBody = transactionNotification;
      } else {
        finalNotificationBody =
            "No transaction updates. Do you have any transaction today?";
      }

      await Future.delayed(const Duration(minutes: 1));

      // Schedule combined notification
      final now = tz.TZDateTime.now(tz.local);
      await transactionschaduleNotification(
        id: 1,
        title: "Financial Update",
        body: finalNotificationBody,
        hour: now.hour,
        minute: (now.minute + 1) % 60,
      );
    } catch (e) {
      print("Error executing and scheduling notifications: $e");
    }
  }
}
