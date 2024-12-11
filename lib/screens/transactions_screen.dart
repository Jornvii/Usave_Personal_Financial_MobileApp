import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/transaction_db.dart';
import '../models/currency_db.dart'; // Import your CurrencyDB model
import '../widgets/add_ddtransaction.dart';
import '../widgets/edit_transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> transactions = [];
  String currencySymbol = '\$'; // Default currency symbol

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _loadTransactions();
  }

  Future<void> _loadCurrency() async {
    final db = CurrencyDB();
    final defaultCurrency = await db.getDefaultCurrency();
    setState(() {
      currencySymbol =
          defaultCurrency?['symbol'] ?? '\$'; // Use default if null
    });
  }

  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();
    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);
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

  void _confirmDeleteTransaction(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = TransactionDB();
              await db.deleteTransaction(id);
              Navigator.pop(context);
              _loadTransactions();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      final dateKey = transaction['date'];
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]?.add(transaction);
    }

    final filteredTransactions = groupedTransactions.entries.where((entry) {
      final transactionDate = DateTime.parse(entry.key);
      return transactionDate.year == selectedDate.year &&
          transactionDate.month == selectedDate.month;
    }).toList()
      ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

    return Scaffold(
      body: Column(
        children: [
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

                      dailyTransactions
                          .sort((a, b) => b['date'].compareTo(a['date']));

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
                            return Slidable(
                                key: ValueKey(transaction['id']),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) async {
                                        final updatedTransaction =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateTransactionScreen(
                                              transaction: transaction,
                                            ),
                                          ),
                                        );

                                        if (updatedTransaction != null) {
                                          final db = TransactionDB();
                                          await db.updateTransaction(
                                            updatedTransaction[
                                                'id'], // Pass the ID
                                            updatedTransaction, // Pass the updated transaction data
                                          );
                                          _loadTransactions();
                                        }
                                      },
                                      backgroundColor: Colors.blue,
                                      icon: Icons.edit,
                                      label: 'Edit',
                                    ),
                                    SlidableAction(
                                      onPressed: (_) =>
                                          _confirmDeleteTransaction(
                                              transaction['id']),
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    transaction['typeCategory'] == 'Income'
                                        ? Icons.arrow_upward
                                        : transaction['typeCategory'] ==
                                                'Expense'
                                            ? Icons.arrow_downward
                                            : Icons.savings,
                                    color:
                                        transaction['typeCategory'] == 'Income'
                                            ? Colors.green
                                            : transaction['typeCategory'] ==
                                                    'Expense'
                                                ? Colors.red
                                                : const Color.fromARGB(
                                                    255, 255, 215, 0),
                                  ),
                                  title: Text(transaction['category']),
                                  trailing: Text(
                                    '$currencySymbol ${transaction['amount']}',
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
                                ));
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
