import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../models/currency_db.dart';
import '../../models/transaction_db.dart';
import '../../widgets/add_ddtransaction.dart';
import '../../widgets/edit_transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;
  List<Map<String, dynamic>> transactions = [];
  String currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _loadTransactions();
    
    selectedStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    selectedEndDate =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  }

  Future<void> _loadCurrency() async {
    final db = CurrencyDB();
    final defaultCurrency = await db.getDefaultCurrency();
    setState(() {
      currencySymbol =
          defaultCurrency?['symbol'] ?? '\$'; 
    });
  }

  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();
    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);
    });
  }

  // Show the date range picker
  void _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          DateTimeRange(start: selectedStartDate, end: selectedEndDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
      });
    }
  }

  void _confirmDeleteTransaction(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Trash?'),
        content: const Text('This will move the transaction to Trashbin ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = TransactionDB();
              await db.moveToTrash(id);
              Navigator.pop(context);
              _loadTransactions();
            },
            child: const Text('Move', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _openAddTransactionScreen() async {
    final newTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddTransactionScreen(selectedDate: selectedStartDate),
      ),
    );

//  Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   DataTransactionTable(transactions: transactions),
//             ),
//           );

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

    // Filter transactions based on the selected date range
    final filteredTransactions = groupedTransactions.entries.where((entry) {
      final transactionDate = DateTime.parse(entry.key);
      return transactionDate
              .isAfter(selectedStartDate.subtract(const Duration(days: 1))) &&
          transactionDate
              .isBefore(selectedEndDate.add(const Duration(days: 1)));
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
                    selectedStartDate = DateTime(
                        selectedStartDate.year, selectedStartDate.month - 1, 1);
                    selectedEndDate = DateTime(
                        selectedStartDate.year, selectedStartDate.month + 1, 0);
                  });
                },
              ),
              TextButton(
                onPressed: _pickDateRange,
                child: Text(
                  DateFormat('MMMM yyyy').format(selectedStartDate),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    selectedStartDate = DateTime(
                        selectedStartDate.year, selectedStartDate.month + 1, 1);
                    selectedEndDate = DateTime(
                        selectedStartDate.year, selectedStartDate.month + 1, 0);
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions available for this period.',
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
                                            updatedTransaction['id'],
                                            updatedTransaction,
                                          );
                                          _loadTransactions();
                                        }
                                      },
                                      backgroundColor: Colors.blue,
                                      icon: Icons.edit,
                                      // label: 'Edit',
                                    ),
                                    SlidableAction(
                                      onPressed: (_) =>
                                          _confirmDeleteTransaction(
                                              transaction['id']),
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      // label: 'Delete',
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
                                  title: Text(
                                    transaction['category'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15),
                                  ),
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
