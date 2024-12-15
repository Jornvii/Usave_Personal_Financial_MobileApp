import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_db.dart';

class DataTransactionTable extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const DataTransactionTable({super.key, required this.transactions});

  @override
  _DataTransactionTableState createState() => _DataTransactionTableState();
}

class _DataTransactionTableState extends State<DataTransactionTable> {
  int currentPage = 0;
  static const int rowsPerPage = 10;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Sort the transactions based on the selected column
  void _sortData(int columnIndex, bool ascending) {
    switch (columnIndex) {
      case 0: // No
        widget.transactions.sort((a, b) => ascending
            ? a['date'].compareTo(b['date'])
            : b['date'].compareTo(a['date']));
        break;
      case 1: // Date
        widget.transactions.sort((a, b) => ascending
            ? a['date'].compareTo(b['date'])
            : b['date'].compareTo(a['date']));
        break;
      case 2: // Category
        widget.transactions.sort((a, b) => ascending
            ? a['category'].compareTo(b['category'])
            : b['category'].compareTo(a['category']));
        break;
      case 3: // Amount
        widget.transactions.sort((a, b) => ascending
            ? a['amount'].compareTo(b['amount'])
            : b['amount'].compareTo(a['amount']));
        break;
      case 4: // Type
        widget.transactions.sort((a, b) => ascending
            ? a['typeCategory'].compareTo(b['typeCategory'])
            : b['typeCategory'].compareTo(a['typeCategory']));
        break;
      case 5: // Description
        widget.transactions.sort((a, b) => ascending
            ? (a['description'] ?? '').compareTo(b['description'] ?? '')
            : (b['description'] ?? '').compareTo(a['description'] ?? ''));
        break;
    }
  }

  // Handle the column sorting
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortData(columnIndex, ascending);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalRows = widget.transactions.length;
    final totalPages = (totalRows / rowsPerPage).ceil();

    // Paginated transactions for the current page
    final paginatedTransactions = widget.transactions
        .skip(currentPage * rowsPerPage)
        .take(rowsPerPage)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Table'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(
                    label: const Text('No'),
                    onSort: (columnIndex, ascending) =>
                        _onSort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Date'),
                    onSort: (columnIndex, ascending) =>
                        _onSort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Category'),
                    onSort: (columnIndex, ascending) =>
                        _onSort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Amount'),
                    onSort: (columnIndex, ascending) =>
                        _onSort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Type'),
                    onSort: (columnIndex, ascending) =>
                        _onSort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Description'),
                    onSort: (columnIndex, ascending) =>
                        _onSort(columnIndex, ascending),
                  ),
                ],
                rows: List.generate(paginatedTransactions.length, (index) {
                  final transaction = paginatedTransactions[index];
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (states) =>
                          index.isEven ? Colors.grey[200] : Colors.white,
                    ),
                    cells: [
                      DataCell(
                          Text('${index + 1 + (currentPage * rowsPerPage)}')),
                      DataCell(Text(transaction['date'])),
                      DataCell(Text(transaction['category'])),
                      DataCell(Text('\$${transaction['amount']}')),
                      DataCell(Text(transaction['typeCategory'])),
                      DataCell(Text(transaction['description'] ?? '')),
                    ],
                  );
                }),
              ),
            ),
          ),
          // Pagination Controls
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${currentPage + 1} of $totalPages',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: currentPage > 0
                            ? () {
                                setState(() {
                                  currentPage--;
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  currentPage++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      // Floating Action Button for exporting data
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40,left: 20),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
            onPressed: () {
            },
            label: const Text("Export Data"),
            icon: const Icon(Icons.play_arrow),
            backgroundColor: const Color.fromARGB(255, 17, 215, 119),
          ),
        ),
      ),
    );
  }
}
