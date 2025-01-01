import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction_db.dart';

class SavingDetailScreen extends StatefulWidget {
  final String category;
  final double? goalAmount;

  const SavingDetailScreen({
    super.key,
    required this.category,
    required this.goalAmount,
  });

  @override
  _SavingDetailScreenState createState() => _SavingDetailScreenState();
}

class _SavingDetailScreenState extends State<SavingDetailScreen> {
  List<Map<String, dynamic>> savingTransactions = [];
  double totalSavings = 0.0;
  int savingPeriodDays = 0;

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

    // Calculate saving period from the first transaction date
    int periodDays = 0;
    if (categoryTransactions.isNotEmpty) {
      categoryTransactions.sort((a, b) =>
          DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      final firstDate = DateTime.parse(categoryTransactions.first['date']);
      final today = DateTime.now();
      periodDays = today.difference(firstDate).inDays;
    }

    setState(() {
      savingTransactions = categoryTransactions;
      totalSavings = total;
      savingPeriodDays = periodDays;
    });
  }

  Widget _buildDonutChart() {
    final progress = (widget.goalAmount != null && widget.goalAmount! > 0)
        ? (totalSavings / widget.goalAmount!).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 75,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      value: progress * 100,
                      color: const Color.fromARGB(255, 42, 221, 48)
                          .withOpacity(.9),
                      radius: 18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: (1 - progress) * 100,
                      color: Colors.grey.shade300,
                      radius: 18,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 45,
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$ ${totalSavings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 74, 254, 80).withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Saving Period',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$savingPeriodDays',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
            fontSize: 14,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction['date'] ?? 'Unknown Date',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '${widget.category} ',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildDonutChart(),
              const SizedBox(height: 15),
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 18, 243, 26).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Saving Total',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '\$ ${totalSavings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          color: Colors.grey,
                          thickness: 1.2,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Goal Amount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.goalAmount != null
                                ? '\$ ${widget.goalAmount!.toStringAsFixed(2)}'
                                : 'Not Set',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
                thickness: 1.2,
                height: 32,
              ),
              const Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
