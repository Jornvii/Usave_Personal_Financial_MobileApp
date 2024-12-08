import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for formatting
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/transaction_db.dart'; // Import your TransactionDB model
import '../models/currency_db.dart';
import '../widgets/list_totalamount.dart'; // Import your CurrencyDB model

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

  String currencySymbol = '\$'; // Default currency symbol
  final NumberFormat currencyFormat =
      NumberFormat('#,##0.00'); // Formatter for numbers

  final CurrencyDB _currencyDB = CurrencyDB();

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency(); // Load the default currency on init
    _loadTransactions(); // Load transactions data
  }

  // Fetch the default currency symbol from CurrencyDB
  Future<void> _loadDefaultCurrency() async {
    final currencies = await _currencyDB.getCurrencies();
    final defaultCurrency = currencies.firstWhere(
      (currency) => currency['isDefault'] == 1,
      orElse: () => {'symbol': '\$'},
    );
    setState(() {
      currencySymbol = defaultCurrency['symbol'];
    });
  }

  // Fetch transactions from the database and prepare data for the chart
  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final allTransactions =
        await db.getTransactions(); // Assuming this fetches all transactions

    Map<String, double> categoryTotals = {
      'Income': 0.0,
      'Expense': 0.0,
      'Saving': 0.0,
    };

    // Calculate total amount per typeCategory (Income, Expense, Saving)
    for (var transaction in allTransactions) {
      if (transaction['typeCategory'] == 'Income') {
        categoryTotals['Income'] =
            categoryTotals['Income']! + transaction['amount'];
      } else if (transaction['typeCategory'] == 'Expense') {
        categoryTotals['Expense'] =
            categoryTotals['Expense']! + transaction['amount'];
      } else if (transaction['typeCategory'] == 'Saving') {
        categoryTotals['Saving'] =
            categoryTotals['Saving']! + transaction['amount'];
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
        ChartData('Expense', expenseTotal, Colors.red.shade400),
        ChartData('Saving', savingTotal, Colors.orange.shade400),
      ];
    });
  }

  // Modernized balance section
  Widget buildBalanceSection() {
    return Column(
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildBalanceCard('Income', incomeTotal,
                const Color.fromARGB(255, 17, 215, 119), Icons.attach_money),
            buildBalanceCard(
                'Expense', expenseTotal, Colors.red, Icons.money_off),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildsavingCard(
                'Saving', savingTotal, Colors.orange, Icons.savings),
            // buildBalanceCard(
            //   'Balance',
            //   incomeTotal - expenseTotal,
            //   Colors.blue,
            //   Icons.account_balance,
            // ),
          ],
        ),
      ],
    );
  }

  // Modern balance card
  Widget buildBalanceCard(
      String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol ${currencyFormat.format(amount)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildsavingCard(
      String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol ${currencyFormat.format(amount)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Donut chart widget
  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        child: SfCircularChart(
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.name,
              yValueMapper: (ChartData data, _) => data.amount,
              radius: '100%',
              innerRadius: '10%',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              animationDuration: 2000,
            ),
          ],
        ),
      ),
    );
  }

  // Chart legend
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
                data.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text(
          'Financial Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.date_range),
          //   onPressed: _selectDateRange,
          // ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListSummaryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              buildBalanceSection(),
              const SizedBox(height: 10),
              const Divider(
                height: 20.0,
                thickness: 3.0,
                color:  Color.fromARGB(255, 17, 215, 119),
                indent: 25.0,
                endIndent: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Balance: ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' $currencySymbol ${currencyFormat.format(incomeTotal - expenseTotal)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: (incomeTotal - expenseTotal) < 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildChart(),
              const SizedBox(height: 20),
              _buildChartLegend(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String name;
  final double amount;
  final Color color;

  ChartData(this.name, this.amount, this.color);
}
