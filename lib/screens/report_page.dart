
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // To format dates
import 'package:path_provider/path_provider.dart'; // To get the local storage path
import 'package:csv/csv.dart'; // For exporting data to CSV
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/transaction_db.dart';
import '../provider/langguages_provider.dart';
import '../widgets/list_totalamount.dart'; // Import LanguageProvider

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  double totalIncome = 0;
  double totalExpense = 0;
  String selectedChartType = 'Doughnut';
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    final db = TransactionDB();

    List<Map<String, dynamic>> transactions;
    if (startDate != null && endDate != null) {
      transactions = await db.getTransactionsByDateRange(startDate!, endDate!);
    } else {
      transactions = await db.getTransactions();
    }

    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
      if (transaction['isIncome'] == 1) {
        income += transaction['amount'];
      } else {
        expense += transaction['amount'];
      }
    }

    setState(() {
      totalIncome = income;
      totalExpense = expense;
      isLoading = false;
    });
  }

  Future<void> _selectDateRange() async {
    final selectedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(start: DateTime.now(), end: DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDateRange != null) {
      setState(() {
        startDate = selectedDateRange.start;
        endDate = selectedDateRange.end;
      });

      _loadData();
    }
  }

  Future<void> _exportToCSV() async {
    final db = TransactionDB();
    final transactions = await db.getTransactions();

    List<List<String>> rows = [];
    rows.add(['Date', 'Description', 'Amount', 'Type']);

    for (var transaction in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction['date'])),
        transaction['description'],
        transaction['amount'].toString(),
        transaction['isIncome'] == 1 ? 'Income' : 'Expense',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/transactions_report.csv';
    final file = File(path);

    await file.writeAsString(csv);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '${Provider.of<LanguageProvider>(context, listen: false).translate('data_exported')} $path'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.translate('report'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
  icon: const Icon(Icons.view_list),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListSummaryScreen()),
    );
  },
),

          // IconButton(
          //   icon: const Icon(Icons.file_copy),
          //   onPressed: _exportToCSV,
          // ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .75,
                      width: MediaQuery.of(context).size.width * .90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${languageProvider.translate('balance')}: \$${(totalIncome - totalExpense).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 20,
                                color: (totalIncome - totalExpense) < 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 0.3,
                            endIndent: 10,
                            indent: 10,
                          ),
                          _buildSummary(languageProvider),
                          const SizedBox(height: 20),
                          _buildChartTypeSelector(languageProvider),
                          const SizedBox(height: 20),
                          Expanded(child: _buildChart(languageProvider)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummary(LanguageProvider languageProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                languageProvider.translate('income'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${totalIncome.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                languageProvider.translate('expense'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${totalExpense.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector(LanguageProvider languageProvider) {
    return DropdownButton<String>(
      value: selectedChartType,
      onChanged: (value) {
        setState(() {
          selectedChartType = value!;
        });
      },
      items: [
        DropdownMenuItem(
          value: 'Doughnut',
          child: Text(languageProvider.translate('donut_chart')),
        ),
        DropdownMenuItem(
          value: 'Line',
          child: Text(languageProvider.translate('line_chart')),
        ),
      ],
    );
  }

  Widget _buildChart(LanguageProvider languageProvider) {
    final data = [
      ChartData(Colors.greenAccent, languageProvider.translate('income'),
          totalIncome),
      ChartData(Colors.redAccent, languageProvider.translate('expense'),
          totalExpense),
    ];

    if (selectedChartType == 'Line') {
      return SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        title: ChartTitle(text: languageProvider.translate('income_vs_expense')),
        legend: const Legend(isVisible: true),
        series: <CartesianSeries>[
          LineSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.name,
            yValueMapper: (ChartData data, _) => data.value,
            color: Colors.blue,
          ),
        ],
      );
    } else {
      return SfCircularChart(
        legend: const Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom,
        ),
        series: <CircularSeries>[
          DoughnutSeries<ChartData, String>(
            dataSource: data,
            pointColorMapper: (ChartData data, _) => data.color,
            xValueMapper: (ChartData data, _) => data.name,
            yValueMapper: (ChartData data, _) => data.value,
            radius: '70%',
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      );
    }
  }
}

class ChartData {
  final Color color;
  final String name;
  final double value;

  ChartData(this.color, this.name, this.value);
}
