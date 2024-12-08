import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/dev_pf.dart';
import 'package:provider/provider.dart';
import '../models/chat_db.dart';
import '../models/transaction_db.dart';
import '../provider/langguages_provider.dart';
import '../provider/theme_provider.dart';
import '../widgets/profile_widget.dart';
import 'category_screen.dart';
import 'saving_goal_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.translate('settings'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const UserProfileWidget(),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(languageProvider.translate('category')),
            // subtitle: Text(languageProvider.translate('view_categories')),
            onTap: () {
              // Navigate to CategoryScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.savings),
            title: Text(languageProvider.translate('saving_goal')),
            // subtitle: Text(
            //   languageProvider.translate('manage_your_saving_goals'),
            // ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SavingGoalScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(languageProvider.translate('language')),
            subtitle: Text(languageProvider
                .translate(languageProvider.selectedLanguage.toLowerCase())),
            onTap: () =>
                _showLanguageSelectionDialog(context, languageProvider),
          ),
          SwitchListTile(
            title: Text(languageProvider.translate('theme')),
            subtitle: Text(
              themeProvider.isDarkTheme
                  ? languageProvider.translate('Dark')
                  : languageProvider.translate('Light'),
            ),
            value: themeProvider.isDarkTheme,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(languageProvider.translate('delete_data')),
            // subtitle: Text(languageProvider.translate('delete_chat_or_all')),
            onTap: () => _showDeleteOptionsDialog(context, languageProvider),
          ),
          ListTile(
            leading: const Icon(Icons.error),
            title: Text(languageProvider.translate('about_us')),
            onTap: () {
              //  Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const DevPfScreen()),
              // );
              Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const DevPfScreen()),
            );
            },
          ),
           Padding(
            padding: const EdgeInsets.all(20),
            child:
             Text(languageProvider.translate('version_app')),
            
            //  Text(
            //   "version 1.0.1",
            //   style: TextStyle(color: Colors.grey),
            // ),
          )
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog(
      BuildContext context, LanguageProvider languageProvider) {
    final languages = ['English', 'Thai', 'Khmer'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return RadioListTile<String>(
                title: Text(languageProvider.translate(language.toUpperCase())),
                value: language,
                groupValue: languageProvider.selectedLanguage,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDeleteOptionsDialog(
      BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('delete_data')),
          content: Text(languageProvider.translate('choose_delete_option')),
          actions: [
            TextButton(
              onPressed: () {
                _deleteAllData(context, languageProvider);
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('delete_all')),
            ),
            TextButton(
              onPressed: () {
                _deleteChatData(context, languageProvider);
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('delete_chat')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _deleteChatData(
      BuildContext context, LanguageProvider languageProvider) async {
    final chatDatabase = ChatDB();
    await chatDatabase.clearMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(languageProvider.translate('chat_data_cleared'))),
    );
  }

  void _deleteAllData(
      BuildContext context, LanguageProvider languageProvider) async {
    // Clear all data from the database
    await TransactionDB().clearTransactions();
// Show a confirmation message after clearing data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(languageProvider.translate('all_data_cleared'))),
    );
  }

  Future<bool?> _showEditConfirmationDialog(
      BuildContext context, LanguageProvider languageProvider) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('edit_saving_goal')),
          content:
              Text(languageProvider.translate('edit_saving_goal_question')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(languageProvider.translate('no')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(languageProvider.translate('yes')),
            ),
          ],
        );
      },
    );
  }
}
