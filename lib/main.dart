import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/chat_bot.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/report_page.dart';
import 'screens/setting_screen.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeProvider and load the saved theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme(); // Load the saved theme preference

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financial Manager',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
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
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
      ? Colors.grey[850] // Dark background color for dark mode
      : Colors.white, // Light background color for light mode
  selectedItemColor: Colors.blueAccent, // Highlight color for active item
  unselectedItemColor: Colors.grey, // Color for inactive items
  showSelectedLabels: true, // Show labels for active items
  showUnselectedLabels: true, // Show labels for inactive items
  selectedFontSize: 14, // Font size for active item labels
  unselectedFontSize: 12, // Font size for inactive item labels
  type: BottomNavigationBarType.fixed, // Ensures proper label alignment
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart),
      label: "Report",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message),
      label: "ChatBot",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: "Settings",
    ),
  ],
),

    );
  }
}
