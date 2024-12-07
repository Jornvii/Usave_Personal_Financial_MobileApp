import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/transaction_db.dart'; // Import your TransactionDB model

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late List<Transaction> transactions = []; // List to hold transactions
  late List<ChartData> chartData = []; // Chart data
  double incomeTotal = 0.0;
  double expenseTotal = 0.0;
  double savingTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Fetch transactions from the database and prepare data for the chart
  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final allTransactions = await db.getTransactions(); // Assuming this fetches all transactions

    Map<String, double> categoryTotals = {
      'Income': 0.0,
      'Expense': 0.0,
      'Saving': 0.0,
    };

    // Calculate total amount per typeCategory (Income, Expense, Saving)
    for (var transaction in allTransactions) {
      if (transaction['typeCategory'] == 'Income') {
        categoryTotals['Income'] = categoryTotals['Income']! + transaction['amount'];
      } else if (transaction['typeCategory'] == 'Expense') {
        categoryTotals['Expense'] = categoryTotals['Expense']! + transaction['amount'];
      } else if (transaction['typeCategory'] == 'Saving') {
        categoryTotals['Saving'] = categoryTotals['Saving']! + transaction['amount'];
      }
    }

    // Update state with totals for each category
    setState(() {
      incomeTotal = categoryTotals['Income']!;
      expenseTotal = categoryTotals['Expense']!;
      savingTotal = categoryTotals['Saving']!;
      chartData = [
        ChartData(
          'Income',
          incomeTotal,
          const Color.fromARGB(255, 17, 215, 119),
        ),
        ChartData('Expense', expenseTotal, Colors.red),
        ChartData('Saving', savingTotal, Colors.yellow),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 8,
        toolbarHeight: 80,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              // Total summary for each category
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySummary('Income', incomeTotal, const Color.fromARGB(255, 17, 215, 119)),
                                          _buildCategorySummary('Expense', expenseTotal, Colors.red),
                   
                   
                    _buildCategorySummary('Saving', savingTotal, Colors.yellow),
                  ],
                ),
              ),

              // Financial Overview Card
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    const Text(
                      "Financial Overview",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      indent: 10,
                      endIndent: 10,
                    ),
                    _buildChart(), // Donut chart widget
                    const SizedBox(height: 20), // Space between chart and legend
                    _buildChartLegend(), // Added color legend below chart
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySummary(String category, double amount, Color color) {
    return Row(
      children: [
        Icon(
          category == 'Income'
              ? Icons.arrow_upward
              : category == 'Expense'
                  ? Icons.arrow_downward
                  : Icons.savings,
          color: color,
          size: 32,
        ),
        const SizedBox(width: 16),
        Text(
          '$category: \$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 280, // Increased height for a bigger chart
        child: SfCircularChart(
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.name,
              yValueMapper: (ChartData data, _) => data.amount,
              radius: '110%', // Adjusted radius for better view
              innerRadius: '50%', // Creating the donut effect
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              animationDuration: 2000, // Smoother animation for the chart
              animationDelay: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: chartData.map((data) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: data.color,
              ),
              const SizedBox(width: 8),
              Text(
                '${data.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ChartData {
  final String name;
  final double amount;
  final Color color;

  ChartData(this.name, this.amount, this.color);
}
