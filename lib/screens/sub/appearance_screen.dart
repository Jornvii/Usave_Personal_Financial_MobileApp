import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/langguages_provider.dart';
import '../../provider/notification_service.dart';
import '../../provider/theme_provider.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool isNotificationOn = false;
  int selectedHour = 9;
  int selectedMinute = 0;
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationOn = prefs.getBool('isNotificationOn') ?? false;
      selectedHour = prefs.getInt('selectedHour') ?? 9;
      selectedMinute = prefs.getInt('selectedMinute') ?? 0;
    });
    if (isNotificationOn) {
      NotificationService().schaduleNotification(
        title: "iSAVE",
        body: "Hello, Do you have any transactions today?🤑",
        hour: selectedHour,
        minute: selectedMinute,
      );
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNotificationOn', isNotificationOn);
    prefs.setInt('selectedHour', selectedHour);
    prefs.setInt('selectedMinute', selectedMinute);
  }

  void _toggleNotification(bool newValue) {
    setState(() {
      isNotificationOn = newValue;
    });
    if (isNotificationOn) {
      NotificationService().schaduleNotification(
        title: "iSAVE",
        body: "Hello, Do you have any transactions today?🤑",
        hour: selectedHour,
        minute: selectedMinute,
      );
    } else {
      NotificationService().cancelAllNotification();
    }
    _savePreferences();
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
    );
    if (pickedTime != null) {
      setState(() {
        selectedHour = pickedTime.hour;
        selectedMinute = pickedTime.minute;
      });
      if (isNotificationOn) {
        NotificationService().schaduleNotification(
          title: "iSAVE",
          body: "Hello, Do you have any transactions today?🤑",
          hour: selectedHour,
          minute: selectedMinute,
        );
      }
      _savePreferences();
    }
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Daily Alert Notification",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<bool>(
                    value: isNotificationOn,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                    ),
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        setState(() {
                          isNotificationOn = newValue;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: true, child: Text("On")),
                      DropdownMenuItem(value: false, child: Text("Off")),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue,width: 0.5),
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            children: [
                              const TextSpan(text: "Set Time : "),
                              TextSpan(
                                text:
                                    "${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    color: Colors
                                        .black,fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50)),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: IconButton(
                              icon: const Icon(
                                Icons.access_time,
                                size: 28,
                                color: Colors.blue,
                              ),
                              onPressed: _pickTime,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Row(
                //   children: [
                //     ElevatedButton(
                //       onPressed: _pickTime,
                //       style: ElevatedButton.styleFrom(
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //         padding: const EdgeInsets.symmetric(
                //             vertical: 12, horizontal: 20),
                //       ),
                //       child: Row(
                //         children: [
                //           Text(
                //             "Set Notification Time: ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}",
                //           ),
                //           IconButton(
                //               onPressed: _pickTime,
                //               icon: const Icon(Icons.edit))
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close",
                          style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _savePreferences();
                        Navigator.pop(context);
                        if (isNotificationOn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Notification Time set: ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                //         DropdownButton<bool>(
                //   value: isNotificationOn,
                //   onChanged: (bool? newValue) {
                //     if (newValue != null) {
                //       _toggleNotification(newValue);
                //     }
                //   },
                //   items: const [
                //     DropdownMenuItem(value: true, child: Text("On")),
                //     DropdownMenuItem(value: false, child: Text("Off")),
                //   ],
                // ),
                // ElevatedButton(
                //   onPressed: _pickTime,
                //   child: Text("Set Notification Time: ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}"),
                // ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: _showNotificationDialog,
                      title: Text(
                        languageProvider.translate('"Daily Notification'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () => _showNotificationDialog(),
                      ),
                    ),
                  ),
                ),
                _appearancemenu(
                  context,
                  languageProvider,
                  Icons.translate,
                  'language',
                  languageProvider
                      .translate(languageProvider.selectedLanguage.toUpperCase()),
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
              ],
            ),
          ),
        ),
      ),
    );
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
