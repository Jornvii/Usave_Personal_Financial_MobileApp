import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/langguages_provider.dart';
import '../provider/theme_provider.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
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
          child: Column(
            children: [
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
              Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Colors.blue,
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
              ),
            ],
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
  return Padding(
    padding: const EdgeInsets.all(5),
    child: Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.blue,
          width: 0.1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
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
    ),
  );
}
