import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:intl/intl.dart';
import '../../models/notification_db.dart';
import '../../models/saving_goaldb.dart';
import '../../models/transaction_db.dart';

const apiKey = "AIzaSyDu8b8nBCg5ZzH0WNEGsLLn_Rb4oZYabVI";

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool loading = false;
  List<Map<String, String>> notifications = [];
  final GoogleGemini gemini = GoogleGemini(apiKey: apiKey);
  final TransactionDB transactionDB = TransactionDB();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadNotifications(); // Load existing notifications
    // _generateNotification1();
    _generateNotification2();
    _startAutoNotification(); // Start timer for periodic updates
  }

  void _scheduleNotification(DateTime scheduledTime) {
    final duration = scheduledTime.difference(DateTime.now());
    Future.delayed(duration, () {
      // _generateNotification1();
      _generateNotification2();
      _scheduleNotification(scheduledTime.add(const Duration(days: 1)));
    });
  }

  void _startAutoNotification() {
    _timer = Timer.periodic(const Duration(hours: 12), (timer) {
      // _generateNotification1();
      _generateNotification2();
    });
  }

  Future<void> _generateNotification1() async {
    setState(() {
      loading = true;
    });
    try {
      // Fetch transactions from the database
      final transactions = await transactionDB.getTransactions();

      // Group and calculate totals
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

      // Generate prompt1 for Gemini
      String prompt1 = """
    Analyze my financial data and generate a short notification:
    - Total Income: \$${totalIncome.toStringAsFixed(2)}
    - Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
    - Total Saving: \$${totalSaving.toStringAsFixed(2)}
    - Balance: \$${balance.toStringAsFixed(2)}
    Key Expense Categories: ${categoryExpenses.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}

    Provide a concise alert based on the data or with a sentence alert me better financial like a quote or sth, ( write all in just short paragraph)
    """;

      // Fetch response from Gemini API
      final response = await gemini.generateFromText(prompt1);
      String notificationText = response.text.trim();

      // Save the notification with a timestamp
      String time = _formatCurrentTime();
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      // Save to database
      final notificationDB = NotificationDB();
      await notificationDB.insertNotification({
        'message': notificationText,
        'time': time,
        'timestamp': timestamp,
      });

      // Refresh notifications list
      await _loadNotifications();
    } catch (e) {
      _showErrorDialog("Error generating notification: $e");
    }
  }
Future<void> _generateNotification2() async {
  setState(() {
    loading = true;
  });
  try {
    // Fetch saving goals from SavingGoalDB
    final savingGoalDB = SavingGoalDB();
    final savingGoals = await savingGoalDB.fetchSavingGoals();

    // Fetch savings transactions from TransactionDB
    final transactions = await transactionDB.getTransactions();
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

    // Compare saving amounts with goals
    List<String> notificationsList = [];
    bool hasValidSavings = false;

    for (var goal in savingGoals) {
      final savingCategory = goal['savingCategory'] as String;
      final goalAmount = goal['goalAmount'] as double;
      final savedAmount = savingsByCategory[savingCategory] ?? 0.0;

      if (savedAmount > 0) {
        hasValidSavings = true; // Ensure at least one valid saving exists

        if (savedAmount >= goalAmount) {
          // Calculate percentage complete
          double percentComplete =
              ((savedAmount / goalAmount) * 100).clamp(0, 100);

          notificationsList.add(
              "🎉 Congratulations! You've reached your saving goal for $savingCategory! You've saved \$${savedAmount.toStringAsFixed(2)} (Goal: \$${goalAmount.toStringAsFixed(2)}) and are ${percentComplete.toStringAsFixed(1)}% complete.");
        } else {
          // Calculate remaining amount and percentage
          final remaining = goalAmount - savedAmount;
          double percentComplete =
              ((savedAmount / goalAmount) * 100).clamp(0, 100);

          notificationsList.add(
              "Keep going! You've saved ${percentComplete.toStringAsFixed(1)}% of your goal for $savingCategory. You're \$${remaining.toStringAsFixed(2)} away from completing it.");
        }
      }
    }

    // Proceed with Gemini prompt only if there are valid savings
    if (hasValidSavings) {
      // Generate prompt2 for Gemini
      String prompt2 = """
      Based on the following saving goal and transaction data, provide a short summary notification or motivation:
      - Saving Goals: ${savingGoals.map((g) => '${g['savingCategory']}: Goal \$${g['goalAmount']}').join(', ')}
      - Savings by Category: ${savingsByCategory.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}
      
      Include a percentage to complete reach for each goal. Provide a short concise and motivational message about achieving these goals and some short idea to reach goal. (write all in just short paragraph)
    """;

      final response = await gemini.generateFromText(prompt2);
      String notificationText = response.text.trim();

      // Save the notification with a timestamp
      String time = _formatCurrentTime();
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      final notificationDB = NotificationDB();
      await notificationDB.insertNotification({
        'message': notificationText,
        'time': time,
        'timestamp': timestamp,
      });

      // Refresh notifications list
      await _loadNotifications();
    }
  } catch (e) {
    _showErrorDialog("Error generating notification: $e");
  } finally {
    setState(() {
      loading = false;
    });
  }
}


  Future<void> _loadNotifications() async {
    final notificationDB = NotificationDB();
    final notificationsFromDB = await notificationDB.getNotifications();

    setState(() {
      notifications = notificationsFromDB.map((n) {
        return {
          'message': n['message'] as String,
          'time': n['time'] as String,
          'id': n['id'].toString(),
        };
      }).toList();
    });
  }

  String _formatCurrentTime() {
    final DateFormat timeFormat = DateFormat.jm();
    return timeFormat.format(DateTime.now());
  }

  void _deleteNotification(int id) async {
    final notificationDB = NotificationDB();
    final result = await notificationDB.deleteNotification(id);
    if (result > 0) {
      setState(() {
        notifications
            .removeWhere((notification) => notification['id'] == id.toString());
      });
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notification"),
        content:
            const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteNotification(id);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        padding: const EdgeInsets.all(2),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final id = int.parse(notification['id']!);

          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              _showDeleteConfirmation(id); // Use the ID here for confirmation
              return false;
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: NotificationCard(
              message: notification['message']!,
              time: notification['time']!,
            ),
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final String message;
  final String time;

  const NotificationCard({
    super.key,
    required this.message,
    required this.time,
  });

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Limit the message length to 150 characters
    final displayMessage = widget.message.length > 100 && !_isExpanded
        ? '${widget.message.substring(0, 60)} ...'
        : widget.message;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: _formatText(displayMessage),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Spacing between time and 'Read More' button
              children: [
                Text(
                  widget.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (widget.message.length > 100)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? "Read Less" : "Read More",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _formatText(String text) {
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    final bulletPattern = RegExp(r'^\* (.*?)');
    final spans = <TextSpan>[];

    if (bulletPattern.hasMatch(text)) {
      final match = bulletPattern.firstMatch(text);
      spans.add(TextSpan(
        text: '• ${match?.group(1)}',
        style: const TextStyle(fontWeight: FontWeight.normal),
      ));
    } else {
      int lastIndex = 0;
      final matches = boldPattern.allMatches(text);
      for (final match in matches) {
        if (match.start > lastIndex) {
          spans.add(TextSpan(
            text: text.substring(lastIndex, match.start),
            style: const TextStyle(fontWeight: FontWeight.normal),
          ));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        lastIndex = match.end;
      }
      if (lastIndex < text.length) {
        spans.add(TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(fontWeight: FontWeight.normal),
        ));
      }
    }
    return TextSpan(
      children: spans,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}
