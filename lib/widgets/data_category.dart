import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_db.dart';
import '../models/currency_db.dart';

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
  String currencySymbol = '\$';
  String selectedFilter = 'All';

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

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedTransactions = {
      'Income': {},
      'Expense': {},
      'Saving': {},
    };

    for (var transaction in transactions) {
      final type = transaction['typeCategory'];
      final category = transaction['category'];

      if (type == 'Saving') {
        if (!groupedTransactions['Saving']!.containsKey(category)) {
          groupedTransactions['Saving']![category] = [];
        }
        groupedTransactions['Saving']![category]?.add(transaction);
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

    // Filtering transactions based on selected date range and filter
    for (var type in groupedTransactions.keys) {
      groupedTransactions[type]!.forEach((category, categoryTransactions) {
        categoryTransactions.removeWhere((transaction) {
          final transactionDate = DateTime.parse(transaction['date']);
          return transactionDate.isBefore(selectedStartDate) ||
              transactionDate.isAfter(selectedEndDate);
        });
      });
    }

    if (selectedFilter != 'All') {
      groupedTransactions.removeWhere((key, value) => key != selectedFilter);
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            ' ${DateFormat('dd/MM/yyyy').format(selectedStartDate)} to ${DateFormat('dd/MM/yyyy').format(selectedEndDate)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Income', child: Text('Income')),
                    DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'Saving', child: Text('Saving')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                  isExpanded: true,
                  dropdownColor:
                      Colors.white, 
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue, 
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500, 
                  ),
                  borderRadius: BorderRadius.circular(
                      12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: groupedTransactions.entries.map((entry) {
                final type = entry.key;
                final categories = entry.value;

                if (categories.isNotEmpty) {
                  return _buildCategorySummary(type, categories);
                }

                return const SizedBox.shrink();
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) =>
          //         DataTransactionTable(transactions: transactions, ),
          //   ),
          // );
        },
        backgroundColor: const Color.fromARGB(255, 17, 215, 119),
        child: const Icon(Icons.visibility),
      ),
    );
  }

  // Method to build a summary block for each category
  Widget _buildCategorySummary(
      String type, Map<String, List<Map<String, dynamic>>> categories) {
    // Calculate total amount and filter out categories with total amount = 0
    double totalAmount = 0;
    final filteredCategories = categories.entries.where((categoryEntry) {
      final categoryTotal = categoryEntry.value
          .fold(0.0, (sum, transaction) => sum + transaction['amount']);
      if (categoryTotal > 0) {
        totalAmount += categoryTotal;
        return true;
      }
      return false;
    }).toList();

    // Skip rendering if no valid categories
    if (filteredCategories.isEmpty) return const SizedBox.shrink();

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
          border: Border.all(
            color: type == 'Income'
                ? Colors.green[200]!
                : type == 'Expense'
                    ? Colors.red[200]!
                    : Colors.orange[200]!,
          ),
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
                        color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...filteredCategories.map((categoryEntry) {
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
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
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
