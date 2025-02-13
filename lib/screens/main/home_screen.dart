import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/sub/sub_home_screen.dart';
import 'package:provider/provider.dart';
import '../../provider/langguages_provider.dart';
import '../sub/addsaving_goal_screen.dart';
import '../sub/notification_screen.dart';
import '../../models/saving_goaldb.dart';
import '../../models/notification_db.dart'; // Assume this is where NotificationDB is implemented

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _notificationCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateNotificationCount(); 
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 2,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/images/logoapp.png'),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              _buildAnimatedText()
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    size: 30,
                  ),
                  onPressed: () async {
                    final hasGoals = await _hasFilledSavingGoals();
                    if (hasGoals) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationScreen()),
                      );
                      _updateNotificationCount();
                    } else {
                      _showSetSavingGoalDialog();
                    }
                  },
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: const SubHomeScreen(transactions: []),
    );
  }

  List<MaterialColor> colorizeColors = [
    Colors.green,
    Colors.yellow,
  ];

  TextStyle colorizeTextStyle = const TextStyle(
    fontSize: 28.0,
  );

  Widget _buildAnimatedText() {
    return AnimatedTextKit(
      animatedTexts: [
        ColorizeAnimatedText(
          'iSAVE',
          textStyle: colorizeTextStyle.copyWith(fontWeight: FontWeight.bold),
          colors: colorizeColors,
        ),
      ],
      isRepeatingAnimation: true,
    );
  }
  
  /// Fetch the current notification count from the database
  Future<void> _updateNotificationCount() async {
    final notificationDB = NotificationDB();
    final count = await notificationDB.getNotificationCount();
    setState(() {
      _notificationCount = count;
    });
  }
  void _startTransactionReload() {
    // Schedule the function to run every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateNotificationCount(); 
       _updateNotificationCount(); 
    });
  }

  /// Check if at least one saving goal is filled
  Future<bool> _hasFilledSavingGoals() async {
    final savingGoals = await SavingGoalDB().fetchSavingGoals();
    return savingGoals
        .any((goal) => goal['goalAmount'] != null && goal['goalAmount'] > 0);
  }

  /// Show a dialog to prompt the user to set a saving goal
  void _showSetSavingGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set a Saving Goal'),
          content: const Text(
              'Please set at least one saving goal before accessing notifications.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SavingGoalScreen()),
                );
              },
              child: const Text('Go to Saving Goals'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

}
