import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_db.dart';
import '../models/saving_db.dart';
import '../theme/theme_provider.dart';
import '../widgets/profile_widget.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
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


UserProfileWidget (),

          // ListTile(
          //   leading: const Icon(Icons.person),
          //   title: const Text('Profile'),
          //   onTap: () {},
          // ),




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
          SwitchListTile(
            title: const Text('Theme'),
            subtitle: Text(themeProvider.isDarkTheme ? 'Dark' : 'Light'),
            value: themeProvider.isDarkTheme,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export data'),
            subtitle: const Text('Export data to excel'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Data'),
            subtitle: const Text('Delete your chat or all data'),
            onTap: () => _showDeleteOptionsDialog(context),
          ),
        ],
      ),
    );
  }

  /// Show a dialog with options to delete data.
  void _showDeleteOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Data'),
          content: const Text(
            'Choose an option to delete your data.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deleteAllData(context); // Clear all data
                Navigator.of(context).pop();
              },
              child: const Text('Delete All Data'),
            ),
            TextButton(
              onPressed: () {
                _deleteChatData(context); // Clear recent chat data
                Navigator.of(context).pop();
              },
              child: const Text('Delete Chat Data'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteChatData(BuildContext context) async {
    final chatDatabase = ChatDB();
    await chatDatabase.clearMessages(); // Clear chat data only
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat data cleared successfully!')),
    );
  }

  void _deleteAllData(BuildContext context) async {
    // await chatDatabase.clearAllData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared successfully!')),
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
