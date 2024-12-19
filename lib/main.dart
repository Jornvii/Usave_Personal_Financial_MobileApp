import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/langguages_provider.dart'; // Ensure this points to your LanguageProvider
import 'provider/theme_provider.dart';
import 'screens/grid_view.dart';
import 'screens/home_screen.dart';
import 'screens/report_screen.dart';
import 'screens/chat_bot.dart';
import 'screens/setting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  
  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(
            create: (_) => languageProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iSave',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home:  const MainScreen(),
      // home:  const SettingUi(transactions: [],),
      // home: const LineChartSample10(),
      localizationsDelegates: const [], 
      supportedLocales: const [
        Locale('en'),
        Locale('th'),
        Locale('km')
      ], // Add more as needed
      locale: Locale(languageProvider.selectedLanguage.toLowerCase()),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MyHomePage(),
     const ReportScreen(),
    const ChatBotScreen(),
    const SettingScreenUi(transactions: [],),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850] 
            : Colors.white, 
            
        selectedItemColor: const Color.fromARGB(255, 52, 214, 136), 
        unselectedItemColor: Colors.grey, 
        showSelectedLabels: true, 
        showUnselectedLabels: true, 
        selectedFontSize: 14, 
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: languageProvider.translate('home'), 
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: languageProvider.translate('report'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy),
            label: languageProvider.translate('chatbot'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: languageProvider.translate('settings'),
          ),
        ],
      ),
    );
  }
}
