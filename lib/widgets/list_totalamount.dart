import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_db.dart';
import '../models/currency_db.dart';
import 'table_transactions.dart';

class ListSummaryScreen extends StatefulWidget {
  const ListSummaryScreen({super.key});

  @override
  _ListSummaryScreenState createState() => _ListSummaryScreenState();
}

class _ListSummaryScreenState extends State<ListSummaryScreen> {
  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime selectedEndDate =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
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

  // void _exportTransaction() {

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Exporting Transactions...")),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // Grouping transactions by their type (Income, Expense, Savings)
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedTransactions = {
      'Income': {},
      'Expense': {},
      'Savings': {}, // Grouping for savings and subcategories
    };

    for (var transaction in transactions) {
      final type = transaction['typeCategory'];
      final category = transaction['category'];

      if (type == 'Savings') {
        if (!groupedTransactions['Savings']!.containsKey(category)) {
          groupedTransactions['Savings']![category] = [];
        }
        groupedTransactions['Savings']![category]?.add(transaction);
      } else {
        if (!groupedTransactions.containsKey(type)) {
          groupedTransactions[type] = {};
        }
        if (!groupedTransactions[type]!.containsKey(category)) {
          groupedTransactions[type]![category] = [];
        }
        groupedTransactions[type]![category]?.add(transaction);
      }
    }

    // Filtering transactions based on selected date range
    for (var type in groupedTransactions.keys) {
      groupedTransactions[type]!.forEach((category, categoryTransactions) {
        categoryTransactions.removeWhere((transaction) {
          final transactionDate = DateTime.parse(transaction['date']);
          return transactionDate.isBefore(selectedStartDate) ||
              transactionDate.isAfter(selectedEndDate);
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(
          child: Text(
            ' ${DateFormat('dd/MM/yyyy').format(selectedStartDate)} to ${DateFormat('dd/MM/yyyy').format(selectedEndDate)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDateRange, // Call date range picker
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: groupedTransactions.entries.map((entry) {
          final type = entry.key;
          final categories = entry.value;

          // To prevent multiple "Savings" blocks
          if (type == 'Savings' && categories.isNotEmpty) {
            return _buildCategorySummary(type, categories);
          }

          // For Income and Expense
          if (categories.isNotEmpty) {
            return _buildCategorySummary(type, categories);
          }

          return const SizedBox.shrink();
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DataTransactionTable(transactions: transactions),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 17, 215, 119),
        child: const Icon(Icons.visibility),
      ),
    );
  }

  // Method to build a summary block for each category
  Widget _buildCategorySummary(
      String type, Map<String, List<Map<String, dynamic>>> categories) {
    double totalAmount = 0;
    categories.forEach((category, transactions) {
      totalAmount += transactions.fold(
          0.0, (sum, transaction) => sum + transaction['amount']);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: type == 'Income'
              ? Colors.green[50]
              : type == 'Expense'
                  ? Colors.red[50]
                  : Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4), // Shadow position
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    type == 'Income'
                        ? Icons.arrow_upward
                        : type == 'Expense'
                            ? Icons.arrow_downward
                            : Icons.savings,
                    color: type == 'Income'
                        ? Colors.green
                        : type == 'Expense'
                            ? Colors.red
                            : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$type (${totalAmount.toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...categories.entries.map((categoryEntry) {
                final category = categoryEntry.key;
                final categoryTransactions = categoryEntry.value;
                double categoryTotal = categoryTransactions.fold(
                    0.0, (sum, transaction) => sum + transaction['amount']);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$category (${categoryTotal.toStringAsFixed(2)})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: type == 'Income'
                            ? Colors.green
                            : type == 'Expense'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...categoryTransactions.map((transaction) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(transaction['date'])),
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${transaction['amount']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: type == 'Income'
                                      ? Colors.green
                                      : type == 'Expense'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
