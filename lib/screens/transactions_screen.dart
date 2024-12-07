import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_db.dart';
import '../widgets/add_ddtransaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();
    setState(() {
      transactions = List<Map<String, dynamic>>.from(data); // Make it mutable
    });
  }

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
      final db = TransactionDB();
      await db.addTransaction({
        ...newTransaction,
        'date': DateFormat('yyyy-MM-dd').format(newTransaction['date']),
        'typeCategory': newTransaction['typeCategory'],
      });
      _loadTransactions(); // Reload transactions
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group transactions by date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      final dateKey = transaction['date'];
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]?.add(transaction);
    }

    // Filter transactions for the selected month
    final filteredTransactions = groupedTransactions.entries.where((entry) {
      final transactionDate = DateTime.parse(entry.key);
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month;
    }).toList()
      ..sort((a, b) => DateTime.parse(b.key)
          .compareTo(DateTime.parse(a.key))); // Sort dates descending

    return Scaffold(
      body: Column(
        children: [
          // Month Selector
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

          // Transactions List
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

                      dailyTransactions.sort((a, b) =>
                          b['date'].compareTo(a['date'])); // Descending order

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          ...dailyTransactions.map((transaction) {
                            return Dismissible(
                              key: Key(transaction['id'].toString()),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: const Text(
                                        'Are you sure you want to delete this transaction?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) async {
                                final db = TransactionDB();
                                await db.deleteTransaction(transaction['id']);
                                _loadTransactions(); // Reload transactions
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  transaction['typeCategory'] == 'Income'
                                      ? Icons.arrow_upward
                                      : transaction['typeCategory'] == 'Expense'
                                          ? Icons.arrow_downward
                                          : Icons.savings,
                                  color: transaction['typeCategory'] == 'Income'
                                      ? Colors.green
                                      : transaction['typeCategory'] ==
                                              'Expense'
                                          ? Colors.red
                                          : const Color.fromARGB(
                                              255, 255, 215, 0),
                                ),
                                title: Text(transaction['category']),
                                trailing: Text(
                                  '${transaction['amount']} USD',
                                  style: TextStyle(
                                    color: transaction['typeCategory'] ==
                                            'Income'
                                        ? Colors.green
                                        : transaction['typeCategory'] ==
                                                'Expense'
                                            ? Colors.red
                                            : const Color.fromARGB(
                                                255, 255, 215, 0),
                                  ),
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
        backgroundColor: const Color.fromARGB(255, 17, 215, 119),
        child: const Icon(Icons.add),
      ),
    );
  }
}
