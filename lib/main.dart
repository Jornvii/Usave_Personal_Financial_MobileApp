import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'provider/langguages_provider.dart';
import 'provider/local_notification_service.dart';
import 'provider/notification_tractions.dart';
import 'provider/theme_provider.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/chat_bot.dart';
import 'screens/main/setting_screenui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request Notification & Storage permissions
  await _checkAndRequestPermissions();

  // Check transaction notification setting
  await checkTransactionNotification();

  // Initialize notification service
  TransactionsNotificationService().initNotification();
  LocalNotificationService().initNotification();

  // Load theme and language settings
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => languageProvider),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> checkTransactionNotification() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isTransactionSwitched = prefs.getBool('isTransactionSwitched') ?? true;

  if (isTransactionSwitched) {
    final notificationService = TransactionsNotificationService();
    await notificationService.initNotification();

    await notificationService.executeTransactionNotifications(
      id: 1,
      title: "Transaction Reminder",
    );
    await notificationService.executeSavingNotifications(
      id: 2,
      title: "Saving Reminder",
    );
  }
}

Future<void> _checkAndRequestPermissions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasAskedPermissions = prefs.getBool('askedPermissions') ?? false;

  if (!hasAskedPermissions) {
    // Request notification permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Request storage permission for Android
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    await prefs.setBool('askedPermissions', true);
  }
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
      home: const SplashScreen(),
      localizationsDelegates: const [],
      supportedLocales: const [Locale('en'), Locale('th'), Locale('km')],
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
  final bool _isTransactionSwitched = true;

  final List<Widget> _screens = [
    const MyHomePage(),
    const ChatBotScreen(),
    const SettingScreenUi(
      transactions: [],
    ),
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
