import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/transaction_db.dart';

class TrashBinScreen extends StatefulWidget {
  const TrashBinScreen({super.key});

  @override
  _TrashBinScreenState createState() => _TrashBinScreenState();
}

class _TrashBinScreenState extends State<TrashBinScreen> {
  List<Map<String, dynamic>> deletedTransactions = [];
  String currencySymbol = '\$'; // Default currency symbol
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDeletedTransactions();
  }

  Future<void> _loadDeletedTransactions() async {
    setState(() {
      isLoading = true;
    });
    final db = TransactionDB();
    final data = await db.getDeletedTransactions();
    setState(() {
      deletedTransactions = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  void _recoverTransaction(int id) async {
    final db = TransactionDB();
    await db.recoverTransaction(id);
    _loadDeletedTransactions();
  }

  void _permanentlyDeleteTransaction(int id) async {
    final db = TransactionDB();
    await db.permanentlyDeleteTransaction(id);
    _loadDeletedTransactions();
  }

  void _recoverAllTransactions() async {
    final db = TransactionDB();
    setState(() {
      isLoading = true;
    });
    for (var transaction in deletedTransactions) {
      await db.recoverTransaction(transaction['id']);
    }
    _loadDeletedTransactions();
  }

  void _deleteAllTransactions() async {
    final db = TransactionDB();
    setState(() {
      isLoading = true;
    });
    for (var transaction in deletedTransactions) {
      await db.permanentlyDeleteTransaction(transaction['id']);
    }
    _loadDeletedTransactions();
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All'),
        content: const Text('Are you sure you want to permanently delete all transactions in the trash? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteAllTransactions();
              Navigator.pop(context);
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRestoreAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore All'),
        content: const Text('Are you sure you want to restore all transactions from the trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _recoverAllTransactions();
              Navigator.pop(context);
            },
            child: const Text('Restore All', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in deletedTransactions) {
      final dateKey = transaction['date'];
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]?.add(transaction);
    }

    final filteredTransactions = groupedTransactions.entries.toList()
      ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash Bin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.safety_check),
            onPressed: deletedTransactions.isEmpty || isLoading
                ? null
                : _showRestoreAllConfirmation,
            tooltip: 'Restore All',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: deletedTransactions.isEmpty || isLoading
                ? null
                : _showDeleteAllConfirmation,
            tooltip: 'Delete All',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No deleted transactions.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final date = filteredTransactions[index].key;
                            final dailyTransactions = filteredTransactions[index].value;

                            dailyTransactions.sort((a, b) => b['date'].compareTo(a['date']));

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    date == DateFormat('yyyy-MM-dd').format(DateTime.now())
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
                                          onPressed: (_) => _recoverTransaction(transaction['id']),
                                          backgroundColor: Colors.green,
                                          icon: Icons.restore,
                                          label: 'Restore',
                                        ),
                                        SlidableAction(
                                          onPressed: (_) => _permanentlyDeleteTransaction(transaction['id']),
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete_forever,
                                          label: 'Delete Forever',
                                        ),
                                      ],
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
                                            : transaction['typeCategory'] == 'Expense'
                                                ? Colors.red
                                                : const Color.fromARGB(255, 255, 215, 0),
                                      ),
                                      title: Text(transaction['category']),
                                      trailing: Text(
                                        '$currencySymbol ${transaction['amount']}',
                                        style: TextStyle(
                                          color: transaction['typeCategory'] == 'Income'
                                              ? Colors.green
                                              : transaction['typeCategory'] == 'Expense'
                                                  ? Colors.red
                                                  : const Color.fromARGB(255, 255, 215, 0),
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
    );
  }
}
