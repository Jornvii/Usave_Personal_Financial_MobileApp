import 'package:flutter/material.dart';

import '../widgets/transactions_screen.dart';
import 'chat_bot.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Chat Bot Test",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: theme.appBarTheme.backgroundColor, // Ensures AppBar has appropriate background
          bottom: TabBar(
            indicatorColor: theme.colorScheme.secondary, // Color for the selected tab indicator
            labelColor: theme.colorScheme.onPrimary, // Color for the selected tab label
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7), // Unselected tab label color
            tabs: const [
              Tab(text: "Report"),
              Tab(text: "Chat Bot"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TransactionsScreen(),
            ChatBotTab(),
          ],
        ),
      ),
    );
  }
}
