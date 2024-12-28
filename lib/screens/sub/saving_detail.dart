import 'package:flutter/material.dart';
import '../../models/transaction_db.dart';

class SavingDetailScreen extends StatefulWidget {
  final String category;
  final double? goalAmount;

  const SavingDetailScreen({
    Key? key,
    required this.category,
    required this.goalAmount,
  }) : super(key: key);

  @override
  _SavingDetailScreenState createState() => _SavingDetailScreenState();
}

class _SavingDetailScreenState extends State<SavingDetailScreen> {
  List<Map<String, dynamic>> savingTransactions = [];
  double totalSavings = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchSavingDetails();
  }

  Future<void> _fetchSavingDetails() async {
    final transactionDB = TransactionDB();

    // Fetch all saving transactions for this category
    final transactions = await transactionDB.getTransactions();
    final categoryTransactions = transactions
        .where((transaction) =>
            transaction['typeCategory'] == 'Saving' &&
            transaction['category'] == widget.category)
        .toList();

    final double total = categoryTransactions.fold(
        0.0, (sum, transaction) => sum + (transaction['amount'] ?? 0.0));

    setState(() {
      savingTransactions = categoryTransactions;
      totalSavings = total; // Calculate total savings
    });

    // Debugging output
    debugPrint('Total Savings: $totalSavings');
    debugPrint('Transactions: $savingTransactions');
  }

  Widget _buildHorizontalBar() {
    final progress = (widget.goalAmount != null && widget.goalAmount! > 0)
        ? (totalSavings / widget.goalAmount!).clamp(0.0, 1.0)
        : 0.0;

    // Debugging output for progress
    debugPrint('Progress: ${progress * 100}%');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Savings Progress',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = progress * constraints.maxWidth;

            return Stack(
              children: [
                Container(
                  height: 20,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 20,
                  width: barWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: progress >= 1.0 ? Colors.green : Colors.blueAccent,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          progress >= 1.0
              ? 'Goal Achieved!'
              : 'Progress: ${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 16,
            color: progress >= 1.0 ? Colors.green : Colors.blueAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingTransactionsList() {
    if (savingTransactions.isEmpty) {
      return const Text(
        'No transactions found for this saving category.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: savingTransactions.length,
      itemBuilder: (context, index) {
        final transaction = savingTransactions[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${transaction['date']}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 77, 76, 76),
                    ),
                  ),
                  Text(
                    '\$${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Saving Details - ${widget.category}',
          style: const TextStyle(fontSize: 20),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category: ${widget.category}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Goal Amount: ${widget.goalAmount != null ? '\$${widget.goalAmount!.toStringAsFixed(2)}' : 'Not Set'}',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),

              // Horizontal Bar Chart for Savings Progress
              _buildHorizontalBar(),

              const SizedBox(height: 20),

              // Total Transaction Saving Amount
              Text(
                'Total Savings: \$${totalSavings.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // List of transactions
              const Text(
                'Saving Transactions:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _buildSavingTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }
}
