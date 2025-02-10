import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/currency_db.dart';
import '../../models/transaction_db.dart';

class DataTransactionTable extends StatefulWidget {
  const DataTransactionTable({super.key});

  @override
  _DataTransactionTableState createState() => _DataTransactionTableState();
}

class _DataTransactionTableState extends State<DataTransactionTable> {
  List<Map<String, dynamic>> transactions = [];
  String currencySymbol = '\$';
  String selectedFilter = 'All';
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

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
      currencySymbol = defaultCurrency?['symbol'] ?? '\$';
    });
  }

  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();
    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = transactions.where((tx) {
      DateTime txDate = DateTime.parse(tx['date']);
      bool isWithinDateRange =
          txDate.isAfter(selectedStartDate.subtract(const Duration(days: 1))) &&
              txDate.isBefore(selectedEndDate.add(const Duration(days: 1)));

      bool matchesFilter =
          selectedFilter == 'All' || tx['typeCategory'] == selectedFilter;
      return isWithinDateRange && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Table"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildDropdownFilter(),
          const SizedBox(height: 10),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text("No transactions available in this range."))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("No")),
                        DataColumn(label: Text("Category")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Type")),
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Description")),
                      ],
                      rows: filteredTransactions.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        Map<String, dynamic> tx = entry.value;

                        return DataRow(cells: [
                          DataCell(Text(index.toString())),
                          DataCell(Text(tx['category'])),
                          DataCell(Text("$currencySymbol ${tx['amount']}")),
                          DataCell(Text(_getCategoryType(tx['typeCategory']))),
                          DataCell(Text(_formatDate(tx['date']))),
                          DataCell(Text(tx['description'] ?? "-")),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 20),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
            onPressed: _exportToCSV,
            label: const Text("Export Data"),
            icon: const Icon(Icons.file_download),
            backgroundColor: const Color.fromARGB(255, 17, 215, 119),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter() {
    return Container(
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
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
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

  String _getCategoryType(dynamic typeCategory) {
    if (typeCategory is int) {
      switch (typeCategory) {
        case 0:
          return "Expense";
        case 1:
          return "Income";
        case 2:
          return "Saving";
        default:
          return "Unknown";
      }
    } else if (typeCategory is String) {
      return typeCategory;
    }
    return "Unknown";
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat("yyyy-MM-dd").format(parsedDate);
  }

Future<void> _exportToCSV() async {
  List<List<String>> csvData = [
    ["No", "Category", "Amount", "Type", "Date", "Description"]
  ];

  final filteredTransactions = transactions.where((tx) {
    DateTime txDate = DateTime.parse(tx['date']);
    bool matchesFilter =
        selectedFilter == 'All' || tx['typeCategory'] == selectedFilter;
    return txDate
            .isAfter(selectedStartDate.subtract(const Duration(days: 1))) &&
        txDate.isBefore(selectedEndDate.add(const Duration(days: 1))) &&
        matchesFilter;
  }).toList();

  for (int i = 0; i < filteredTransactions.length; i++) {
    Map<String, dynamic> tx = filteredTransactions[i];
    csvData.add([
      (i + 1).toString(),
      tx['category'],
      "${tx['amount']}",
      _getCategoryType(tx['typeCategory']),
      _formatDate(tx['date']),
      tx['description'] ?? "-"
    ]);
  }

  // Convert CSV data
  String csv = const ListToCsvConverter(fieldDelimiter: ",").convert(csvData);

  List<int> csvBytes = utf8.encode("\uFEFF" + csv);

  String formattedDateTime = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
  String fileName = "transaction_$formattedDateTime.csv";

  Directory? downloadsDirectory;
  if (Platform.isAndroid) {
    downloadsDirectory = Directory('/storage/emulated/0/Download');
  } else {
    downloadsDirectory = await getDownloadsDirectory();
  }

  if (downloadsDirectory != null) {
    final filePath = "${downloadsDirectory.path}/$fileName";
    final file = File(filePath);

    try {
      await file.writeAsBytes(csvBytes); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV Exported: $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: ${e.toString()}")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to access download directory")),
    );
  }
}
}
