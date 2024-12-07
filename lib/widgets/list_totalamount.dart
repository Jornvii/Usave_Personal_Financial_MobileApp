import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_db.dart';
import 'package:share_plus/share_plus.dart';

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

  // Load transactions from the database
  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();

    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);

      // Calculate totals for Income categories
      incomeCategoryTotals = _calculateCategoryTotals(
          transactions.where((t) => t['typeCategory'] == 1).toList());

      // Calculate totals for Expense categories
      expenseCategoryTotals = _calculateCategoryTotals(
          transactions.where((t) => t['typeCategory'] == 0).toList());
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

  // Export transactions as CSV
  Future<void> _exportData() async {
    String csvData = "Date,Category,Amount,Type\n";
    for (var transaction in transactions) {
      csvData +=
          "${_formatDate(transaction['date'])},${transaction['category']},${transaction['amount']},${transaction['typeCategory'] == 1 ? 'Income' : 'Expense'}\n";
    }

    // Share the CSV data
    await Share.share(csvData, subject: 'Transaction Data');
  }

  // Navigate to the View All Data screen
  void _viewAllData() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAllDataScreen(transactions: transactions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _viewAllData,
              child: const Text('View All Data'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCategorySection('Income', incomeCategoryTotals, true),
                  const SizedBox(height: 20),
                  _buildCategorySection(
                      'Expense', expenseCategoryTotals, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build UI section for each category type (Income/Expense)
  Widget _buildCategorySection(
      String title, Map<String, double> categoryTotals, bool typeCategory) {
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
          return _buildCategoryRow(entry.key, entry.value, typeCategory);
        }),
      ],
    );
  }

  // Build each category row with date, category, and amount
  Widget _buildCategoryRow(String category, double totalAmount, bool typeCategory) {
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
                  color: typeCategory ? Colors.green : Colors.red,
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
              return _buildTransactionRow(transaction, typeCategory);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Build a transaction row (category, date, amount)
  Widget _buildTransactionRow(Map<String, dynamic> transaction, bool typeCategory) {
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

class ViewAllDataScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const ViewAllDataScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PaginatedDataTable(
          header: const Text('Transaction List'),
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Description')),
          ],
          source: TransactionsDataSource(transactions),
          rowsPerPage: 10, 
          showCheckboxColumn: false, 
        ),
      ),
    );
  }
}

class TransactionsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> transactions;

  TransactionsDataSource(this.transactions);

  @override
  DataRow? getRow(int index) {
    if (index >= transactions.length) return null;

    final transaction = transactions[index];

    return DataRow(cells: [
      DataCell(Text((index + 1).toString())), // Row number
      DataCell(Text(_formatDate(transaction['date']))),
      DataCell(Text(transaction['category'] ?? 'Uncategorized')),
      DataCell(Text(NumberFormat("#,##0.00", "en_US")
          .format(transaction['amount'] ?? 0.0))),
      DataCell(Text(transaction['typeCategory'] == 1 ? 'Income' : 'Expense')),
      DataCell(Text(transaction['description'] ?? '')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => transactions.length;

  @override
  int get selectedRowCount => 0;

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return '';
    }
  }
}
