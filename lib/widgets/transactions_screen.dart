import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> transactions = [];

  void _pickMonth() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newDate != null) {
      setState(() {
        selectedDate = DateTime(newDate.year, newDate.month);
      });
    }
  }

  void _openAddTransactionScreen() async {
    final newTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(selectedDate: selectedDate),
      ),
    );

    if (newTransaction != null) {
      setState(() {
        transactions.add(newTransaction);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group transactions by date and sort by descending order
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction['date']);
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]?.add(transaction);
    }

    // Filter and sort transactions for the selected month
    final filteredTransactions = groupedTransactions.entries.where((entry) {
      final transactionDate = DateTime.parse(entry.key);
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month;
    }).toList()
      ..sort((a, b) => DateTime.parse(b.key)
          .compareTo(DateTime.parse(a.key))); // Sort dates descending

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Transactions')),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          // Month navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month - 1);
                  });
                },
              ),
              TextButton(
                onPressed: _pickMonth,
                child: Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month + 1);
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions available for this month.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final date = filteredTransactions[index].key;
                      final dailyTransactions =
                          filteredTransactions[index].value;

                      // Sort transactions by time within the same day
                      dailyTransactions.sort((a, b) =>
                          b['date'].compareTo(a['date'])); // Descending order

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              date ==
                                      DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now())
                                  ? 'Today'
                                  : date,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          // Transactions for the date
                          ...dailyTransactions.map((transaction) {
                            return ListTile(
                              leading: Icon(
                                transaction['isIncome']
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: transaction['isIncome']
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(transaction['category']),
                              subtitle: Text(transaction['description'] ?? ''),
                              trailing: Text(
                                '${transaction['amount']} USD',
                                style: TextStyle(
                                  color: transaction['isIncome']
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionScreen,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
