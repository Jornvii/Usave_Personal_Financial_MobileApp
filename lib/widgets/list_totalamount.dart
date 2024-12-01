import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_db.dart'; // Your transaction database model

class ListSummaryScreen extends StatefulWidget {
  const ListSummaryScreen({super.key});

  @override
  _ListSummaryScreenState createState() => _ListSummaryScreenState();
}

class _ListSummaryScreenState extends State<ListSummaryScreen> {
  List<Map<String, dynamic>> transactions = [];
  Map<String, double> incomeCategoryTotals = {};
  Map<String, double> expenseCategoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Fetch transactions from the database
  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();

    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);

      // Calculate totals for Income categories
      incomeCategoryTotals = _calculateCategoryTotals(
          transactions.where((t) => t['isIncome'] == 1).toList());

      // Calculate totals for Expense categories
      expenseCategoryTotals = _calculateCategoryTotals(
          transactions.where((t) => t['isIncome'] == 0).toList());
    });
  }

  // Calculate total for each category
  Map<String, double> _calculateCategoryTotals(
      List<Map<String, dynamic>> filteredTransactions) {
    Map<String, double> categoryTotals = {};
    for (var transaction in filteredTransactions) {
      final category = transaction['category'] ?? 'Uncategorized';
      final amount = transaction['amount']?.toDouble() ?? 0.0;

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }
    return categoryTotals;
  }

  // Format date to 'dd/MM/yyyy'
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCategorySection('Income', incomeCategoryTotals, true),
            const SizedBox(height: 20),
            _buildCategorySection('Expense', expenseCategoryTotals, false),
          ],
        ),
      ),
    );
  }

  // Build UI section for each category type (Income/Expense)
  Widget _buildCategorySection(
      String title, Map<String, double> categoryTotals, bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        if (categoryTotals.isEmpty)
          const Text('No data available',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ...categoryTotals.entries.map((entry) {
          return _buildCategoryRow(entry.key, entry.value, isIncome);
        }).toList(),
      ],
    );
  }

  // Build each category row with date, category, and amount
  Widget _buildCategoryRow(String category, double totalAmount, bool isIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
   
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '${NumberFormat("#,##0.00", "en_US").format(totalAmount)} ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isIncome
                      ? Colors.green
                      : Colors.red, // Green for income, red for expense
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          const SizedBox(height: 8),
          // Transaction list for each category
          Column(
            children: transactions
                .where((t) => t['category'] == category)
                .map((transaction) {
              return _buildTransactionRow(transaction, isIncome);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Build a transaction row (category, date, amount)
  Widget _buildTransactionRow(Map<String, dynamic> transaction, bool isIncome) {
    final date = _formatDate(transaction['date']);
    final amount = transaction['amount']?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            '${NumberFormat("#,##0.00", "en_US").format(amount)} ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
