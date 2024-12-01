import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_db.dart';
import '../models/saving_db.dart';
import '../provider/langguages_provider.dart';
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

  Future<void> _fetchSavingGoal() async {
    final goal = await _savingGoalDB.fetchSavingGoal();
    setState(() {
      _savingGoal = goal;
    });
  }

  Future<void> _saveSavingGoal(double goal) async {
    await _savingGoalDB.saveSavingGoal(goal);
    setState(() {
      _savingGoal = goal;
    });
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
            subtitle: Text(languageProvider.translate('view_categories')),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.savings),
            title: Text(languageProvider.translate('saving_goal')),
            subtitle: Text(
              _savingGoal == null
                  ? languageProvider.translate('not_set')
                  : '${languageProvider.translate('your_saving_goal')}: $_savingGoal',
            ),
            onTap: () async {
              if (_savingGoal != null) {
                final shouldEdit = await _showEditConfirmationDialog(context, languageProvider);
                if (shouldEdit == true) {
                  await _showSavingGoalDialog(context, languageProvider);
                }
              } else {
                await _showSavingGoalDialog(context, languageProvider);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(languageProvider.translate('language')),
            subtitle: Text(languageProvider.translate(languageProvider.selectedLanguage.toLowerCase())),
            onTap: () => _showLanguageSelectionDialog(context, languageProvider),
          ),
          SwitchListTile(
            title: Text(languageProvider.translate('theme')),
            subtitle: Text(
              themeProvider.isDarkTheme
                  ? languageProvider.translate('dark')
                  : languageProvider.translate('light'),
            ),
            value: themeProvider.isDarkTheme,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(languageProvider.translate('export_data')),
            subtitle: Text(languageProvider.translate('export_to_excel')),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(languageProvider.translate('delete_data')),
            subtitle: Text(languageProvider.translate('delete_chat_or_all')),
            onTap: () => _showDeleteOptionsDialog(context, languageProvider),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context, LanguageProvider languageProvider) {
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

  void _showDeleteOptionsDialog(BuildContext context, LanguageProvider languageProvider) {
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

  void _deleteChatData(BuildContext context, LanguageProvider languageProvider) async {
    final chatDatabase = ChatDB();
    await chatDatabase.clearMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(languageProvider.translate('chat_data_cleared'))),
    );
  }

  void _deleteAllData(BuildContext context, LanguageProvider languageProvider) async {
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
          content: Text(languageProvider.translate('edit_saving_goal_question')),
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

  Future<void> _showSavingGoalDialog(
      BuildContext context, LanguageProvider languageProvider) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('set_saving_goal')),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: languageProvider.translate('enter_saving_goal'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                final input = controller.text;
                if (input.isNotEmpty) {
                  final goal = double.tryParse(input);
                  if (goal != null) {
                    await _saveSavingGoal(goal);
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('submit')),
            ),
          ],
        );
      },
    );
  }
}
