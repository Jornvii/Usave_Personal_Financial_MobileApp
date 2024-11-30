import 'package:flutter/material.dart';
import '../models/saving_db.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double? _savingGoal;
  final SavingGoalDB _savingGoalDB = SavingGoalDB();

  @override
  void initState() {
    super.initState();
    _fetchSavingGoal();
  }

  /// Fetch the saving goal from the database.
  Future<void> _fetchSavingGoal() async {
    final goal = await _savingGoalDB.fetchSavingGoal();
    setState(() {
      _savingGoal = goal;
    });
  }

  /// Save or update the saving goal in the database.
  Future<void> _saveSavingGoal(double goal) async {
    await _savingGoalDB.saveSavingGoal(goal);
    setState(() {
      _savingGoal = goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('View your profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Category'),
            subtitle: const Text('View your categories'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.savings),
            title: const Text('Saving Goal'),
            subtitle: Text(
              _savingGoal == null
                  ? 'Not set'
                  : 'Your saving goal: $_savingGoal',
            ),
            onTap: () async {
              if (_savingGoal != null) {
                // Ask the user if they want to edit the saving goal
                final shouldEdit = await _showEditConfirmationDialog(context);
                if (shouldEdit == true) {
                  await _showSavingGoalDialog(context);
                }
              } else {
                // Prompt to set saving goal directly
                await _showSavingGoalDialog(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export data'),
            subtitle: const Text('Export data to excel'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Show a dialog asking the user if they want to edit the saving goal.
  Future<bool?> _showEditConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Saving Goal'),
          content: const Text('Do you want to edit your saving goal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Don't edit
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Edit
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  /// Show a dialog to set or update the saving goal.
  Future<void> _showSavingGoalDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Your Saving Goal'),
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
                    await _saveSavingGoal(goal); // Save to database
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
