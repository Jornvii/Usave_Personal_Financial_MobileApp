import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sqflite/sqflite.dart'; // Ensure you've added the sqflite package in pubspec.yaml

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  final Map<String, double> dataMap = {"Income": 0, "Expense": 0};

  final List<Color> colorList = [
    Colors.green, // Income
    Colors.red,   // Expense
  ];

  @override
  void initState() {
    super.initState();
    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    // Replace with your actual database initialization and transaction table structure
    final database = await openDatabase('transactiondb.db');
    final List<Map<String, dynamic>> transactions =
        await database.query('transactions');

    double incomeTotal = 0;
    double expenseTotal = 0;

    for (var transaction in transactions) {
      if (transaction['isIncome'] == 1) {
        incomeTotal += transaction['amount'];
      } else {
        expenseTotal += transaction['amount'];
      }
    }

    setState(() {
      dataMap['Income'] = incomeTotal;
      dataMap['Expense'] = expenseTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Report"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: dataMap['Income'] == 0 && dataMap['Expense'] == 0
            ? const Text(
                "No data available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            : PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(milliseconds: 800),
                chartRadius: MediaQuery.of(context).size.width / 2.5,
                colorList: colorList,
                chartType: ChartType.disc,
                legendOptions: const LegendOptions(
                  legendPosition: LegendPosition.bottom,
                  showLegendsInRow: true,
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: false,
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                ),
              ),
      ),
    );
  }
}
