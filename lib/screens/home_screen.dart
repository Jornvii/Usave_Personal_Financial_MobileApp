import 'package:flutter/material.dart';
import 'saving_goal_screen.dart';
import 'notification_screen.dart';
import '../models/saving_goaldb.dart';
import 'transactions_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
  }

  /// Check if at least one saving goal is filled
  Future<bool> _hasFilledSavingGoals() async {
    final savingGoals = await SavingGoalDB().fetchSavingGoals();
    return savingGoals.any((goal) => goal['goalAmount'] != null && goal['goalAmount'] > 0);
  }

  /// Show a dialog to prompt the user to set a saving goal
  void _showSetSavingGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set a Saving Goal'),
          content: const Text('Please set at least one saving goal before accessing notifications.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavingGoalScreen()),
                );
              },
              child: const Text('Go to Saving Goals'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _notificationCount++;
              });
            },
            icon: const Icon(Icons.add),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () async {
                    final hasGoals = await _hasFilledSavingGoals();
                    if (hasGoals) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    } else {
                      _showSetSavingGoalDialog();
                    }
                  },
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: TransactionsScreen(),
      ),
    );
  }
}
