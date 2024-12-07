import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/saving_goaldb.dart';
import '../models/transaction_db.dart'; // Your transaction database model

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool loading = false;
  List<Map<String, String>> notifications = [];

  @override
  void initState() {
    super.initState();
  }

  /// Function to generate financial notifications
  Future<void> _generateFinancialNotification() async {
    setState(() {
      loading = true;
    });

    try {
      // Fetch income, expenses, and saving goals
      double income = await TransactionDB().getTotalIncome();
      double expenses = await TransactionDB().getTotalExpenses();

      // Fetch all saving goals
      final savingGoals = await SavingGoalDB().fetchSavingGoals();

      if (savingGoals.isEmpty) {
        _showNoSavingGoalsDialog();
        setState(() {
          loading = false;
        });
        return;
      }

      // Calculate the first goal amount as an example (expand as needed)
      double savingsGoal = savingGoals[0]['goalAmount'] ?? 0.0;
      double savingsProgress = income - expenses;

      // Generate advice
      String message =
          _generateAdvice(income, expenses, savingsGoal, savingsProgress);

      // Get the current time formatted as "hour:minute AM/PM"
      String time = _formatCurrentTime();

      setState(() {
        notifications.add({
          "message": message,
          "time": time,
        });
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  /// Generates financial advice based on calculations
  String _generateAdvice(
      double income, double expenses, double savingsGoal, double savingsProgress) {
    if (savingsGoal <= 0) {
      return "Your saving goal is not properly set. Please update your saving goals.";
    }


    if (savingsProgress < savingsGoal) {
      return "Based on your income of \$${income.toStringAsFixed(2)}, expenses of \$${expenses.toStringAsFixed(2)}, and a savings goal of \$${savingsGoal.toStringAsFixed(2)}, you're saving \$${savingsProgress.toStringAsFixed(2)}. Consider cutting discretionary expenses by 10% to reach your goal faster.";
    } else {
      return "Great job! You've saved \$${savingsProgress.toStringAsFixed(2)} towards your goal of \$${savingsGoal.toStringAsFixed(2)}. Keep up the great work!";
    }
  }

  /// Format the current time to "hour:minute AM/PM"
  String _formatCurrentTime() {
    final DateFormat timeFormat = DateFormat.jm();
    return timeFormat.format(DateTime.now());
  }

  /// Delete a notification
  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  /// Show a dialog for deleting a notification
  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Notification"),
          content:
              const Text("Are you sure you want to delete this notification?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNotification(index);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  /// Show a dialog if no saving goals are available
  void _showNoSavingGoalsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Saving Goals"),
          content: const Text(
              "You haven't set any saving goals yet. Please set at least one saving goal to generate notifications."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  /// Show an error dialog if something goes wrong
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Okay"),
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
        title: const Text("Financial Notifications"),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _generateFinancialNotification,
                  child: const Text("Generate Notification"),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        _showDeleteDialog(context, index);
                        return false;
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: NotificationCard(
                        message: notifications[index]["message"]!,
                        time: notifications[index]["time"]!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

/// NotificationCard Widget
class NotificationCard extends StatelessWidget {
  final String message;
  final String time;

  const NotificationCard({super.key, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(time,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
