import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/langguages_provider.dart';
import '../../provider/local_notification_service.dart';
import '../../provider/notification_tractions.dart';
import '../../provider/theme_provider.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool isNotificationOn = false;
  bool _isTransactionSwitched = false;
  @override
  void initState() {
    super.initState();
    // _loadPreferences();
    _loadPreferencestransaction();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Appearance",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _appearancemenu(
                  context,
                  languageProvider,
                  Icons.translate,
                  'language',
                  languageProvider.translate(
                      languageProvider.selectedLanguage.toUpperCase()),
                  () => _showLanguageSelectionDialog(context, languageProvider),
                  Colors.lightBlue,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      width: 0.1,
                    ),
                  ),
                  child: InkWell(
                    child: SwitchListTile(
                      title: Text(languageProvider.translate('theme')),
                      subtitle: Text(
                        themeProvider.isDarkTheme
                            ? languageProvider.translate('Dark')
                            : languageProvider.translate('Light'),
                      ),
                      value: themeProvider.isDarkTheme,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      width: 0.1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      child: ListTile(
                        title: const Text("Show Notifications"),
                        trailing: DropdownButton<String>(
                          value: _isTransactionSwitched ? "On" : "Off",
                          items: ["On", "Off"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            bool newValueBool = newValue == "On";
                            setState(() {
                              _isTransactionSwitched = newValueBool;
                            });
                            await _savePreferencestransaction();

                            if (newValueBool) {
                              final notificationService = 
                                  TransactionsNotificationService();
                              await notificationService.initNotification();

                              await notificationService
                                  .executeTransactionNotifications(
                                id: 1,
                                title: "Transaction Reminder",
                              );

                              await notificationService
                                  .executeSavingNotifications(
                                id: 2,
                                title: "Saving Reminder",
                              );

                            } else {
                              LocalNotificationService()
                                  .cancelAllNotification();
                            }

                            await _savePreferencestransaction();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//SharedPreferences for transaction notification
  Future<void> _loadPreferencestransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTransactionSwitched = prefs.getBool('isTransactionSwitched') ?? true;
    });
  }

  Future<void> _savePreferencestransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTransactionSwitched', _isTransactionSwitched);
  }
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

Widget _appearancemenu(
  BuildContext context,
  LanguageProvider languageProvider,
  IconData appearanceicon,
  String appearancetitle,
  String apearanceSub,
  VoidCallback onTap,
  Color appearancemenucolor,
) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: const BorderSide(
        color: Colors.blue,
        width: 0.1,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: ListTile(
        leading: Icon(appearanceicon, size: 25, color: appearancemenucolor),
        title: Text(
          languageProvider.translate(appearancetitle),
          // appearancetitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(apearanceSub),
      ),
    ),
  );
}
