import 'package:flutter/material.dart';
import '../models/saving_db.dart';
import 'notification_screen.dart';
import 'transactions_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? _savingGoal;
  final SavingGoalDB _savingGoalDB = SavingGoalDB();

  @override
  void initState() {
    super.initState();
    _fetchSavingGoal();
  }

  /// Fetch the saving goal using `SavingGoalDB`.
  Future<void> _fetchSavingGoal() async {
    final goal = await _savingGoalDB.fetchSavingGoal();
    setState(() {
      _savingGoal = goal;
    });
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
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              if (_savingGoal == null) {
                // Show dialog to input saving goal
                await _showSavingGoalDialog(context);
              }
              if (_savingGoal != null) {
                // Navigate to NotificationScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: TransactionsScreen(),
      ),
    );
  }

  /// Show a dialog to set or update the saving goal.
  Future<void> _showSavingGoalDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pleasee Your Saving Goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(hintText: 'Enter saving goal amount'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final input = controller.text;
                if (input.isNotEmpty) {
                  final goal = double.tryParse(input);
                  if (goal != null) {
                    await _savingGoalDB.saveSavingGoal(goal); // Save to database
                    setState(() {
                      _savingGoal = goal;
                    });
                  }
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
