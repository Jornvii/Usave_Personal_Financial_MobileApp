import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_db.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold),),
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
}
