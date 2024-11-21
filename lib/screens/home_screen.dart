import 'package:flutter/material.dart';

import 'chat_bot.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
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
          bottom: const TabBar(
            tabs: [
              Tab(text: "Report"),
              Tab(text: "Chat Bot"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ReportTab(),
            ChatBotTab(),
          ],
        ),
      ),
    );
  }
}

class ReportTab extends StatelessWidget {
  const ReportTab({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          '18/11/2024 - 24/11/2024',
          style: TextStyle(color: Colors.red),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(20.0),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.redAccent,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Expense: 409.0', style: TextStyle(color: Colors.white)),
                        Text('Income: 5000.0', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: const [
                ListTile(
                  leading: Icon(Icons.card_giftcard, color: Colors.green),
                  title: Text('Bonus'),
                  trailing: Text(
                    '5000.00',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.watch_later_outlined, color: Colors.red),
                  title: Text('Miscellaneous'),
                  trailing: Text(
                    '-409.00',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
