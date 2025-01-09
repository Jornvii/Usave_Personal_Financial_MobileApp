import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_db.dart';

const apiKey = "AIzaSyDu8b8nBCg5ZzH0WNEGsLLn_Rb4oZYabVI";

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool loading = false;
  List<Map<String, String>> notifications = [];
  final GoogleGemini gemini = GoogleGemini(apiKey: apiKey);
  final TransactionDB transactionDB = TransactionDB();

  @override
  void initState() {
    super.initState();
    _generateNotification();
  }

  Future<void> _generateNotification() async {
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

      // Generate prompt for Gemini
      String prompt = """
      Analyze this financial data and generate a short notification:
      - Total Income: \$${totalIncome.toStringAsFixed(2)}
      - Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
      - Total Saving: \$${totalSaving.toStringAsFixed(2)}
      - Balance: \$${balance.toStringAsFixed(2)}
      Key Expense Categories: ${categoryExpenses.entries.map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}
      Provide a concise alert based on the data, no longer than one sentence.
    """;

      // Fetch response from Gemini API
      final response = await gemini.generateFromText(prompt);
      String notificationText = response.text.trim();

      // Save the notification with a timestamp
      String time = _formatCurrentTime();
      setState(() {
        notifications.add({"message": notificationText, "time": time});
      });
    } catch (e) {
      _showErrorDialog("Error fetching transactions: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  String _formatCurrentTime() {
    final DateFormat timeFormat = DateFormat.jm();
    return timeFormat.format(DateTime.now());
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _generateNotification,
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
                        _deleteNotification(index);
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

class NotificationCard extends StatelessWidget {
  final String message;
  final String time;

  const NotificationCard({Key? key, required this.message, required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
