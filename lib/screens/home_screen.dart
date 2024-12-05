import 'package:flutter/material.dart';
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
                    // if (_savingGoal == null) {
                    //   await _showSavingGoalDialog(context);
                    // }
                    // if (_savingGoal != null) {
                      
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const NotificationScreen()),
                    //   );
                    // }
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
            decoration: const InputDecoration(
                hintText:
                    'Enter saving goal amount to get daily notification from ai'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // final input = controller.text;
                // if (input.isNotEmpty) {
                //   final goal = double.tryParse(input);
                //   if (goal != null) {
                //     await _savingGoalDB
                //         .saveSavingGoal(goal); // Save to database
                //     setState(() {
                //       _savingGoal = goal;
                //     });
                //   }
                // }
                // Navigator.of(context).pop(); 
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
