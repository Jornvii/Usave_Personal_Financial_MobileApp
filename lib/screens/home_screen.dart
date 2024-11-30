import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'transactions_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // centerTitle: true,
        // backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Chat Bot',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: TransactionsScreen(),
      ),
    );
  }
}
