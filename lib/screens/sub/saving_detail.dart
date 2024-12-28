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
  }

  Widget _buildHorizontalBar() {
    final progress = (widget.goalAmount != null && widget.goalAmount! > 0)
        ? (totalSavings / widget.goalAmount!).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
                    gradient: LinearGradient(
                      colors: [
                         const Color.fromARGB(255, 33, 243, 86).withOpacity(0.6),
                        progress >= 1.0 ? const Color.fromARGB(255, 0, 252, 92) : const Color.fromARGB(255, 33, 243, 86),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          progress >= 1.0
              ? '🎉 Goal Achieved!'
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
      return const Center(
        child: Text(
          'No Saving transactions ',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: savingTransactions.length,
      itemBuilder: (context, index) {
        final transaction = savingTransactions[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction['date'] ?? 'Unknown Date',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Saved: \$${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
               
              ],
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
        title: Text(
          '${widget.category} Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Amount Section
              Text(
                'Goal Amount: ${widget.goalAmount != null ? '\$${widget.goalAmount!.toStringAsFixed(2)}' : 'Not Set'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Bar Chart
              _buildHorizontalBar(),

              const SizedBox(height: 24),

              // Total Savings Section
              RichText(
                text: TextSpan(
                  text: 'Total Savings: ',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '\$${totalSavings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                color: Colors.grey,
                thickness: 1.2,
                height: 32,
              ),

              // Transactions Section
              const Text(
                'Saving Transactions',
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
