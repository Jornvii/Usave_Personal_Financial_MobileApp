import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'input_new.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String selectedMonth = DateFormat('MM/yyyy').format(DateTime.now());
  double totalBalance = 409.0; // Example data
  List<Map<String, dynamic>> transactions = [
    {'category': 'Bonus', 'amount': 5000.0, 'isIncome': true},
    {'category': 'Miscellaneous', 'amount': -409.0, 'isIncome': false},
  ];

  void _openAddTransactionScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionScreen()),
    );
    // Refresh data after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Change to previous month logic
                },
              ),
              TextButton(
                onPressed: () async {
                  // Month picker logic
                },
                child: Text(selectedMonth),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  // Change to next month logic
                },
              ),
            ],
          ),
          Text(
            '\$ $totalBalance',
            style: const TextStyle(fontSize: 24, color: Colors.blue),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: Icon(
                    transaction['isIncome'] ? Icons.arrow_upward : Icons.arrow_downward,
                    color: transaction['isIncome'] ? Colors.green : Colors.red,
                  ),
                  title: Text(transaction['category']),
                  trailing: Text(
                    '${transaction['amount']} USD',
                    style: TextStyle(
                      color: transaction['isIncome'] ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
