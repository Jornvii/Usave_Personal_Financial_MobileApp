import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/transaction_db.dart';
import '../../models/currency_db.dart';
import '../../provider/langguages_provider.dart';
import '../../widgets/summary_category.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late List<Transaction> transactions = [];
  late List<ChartData> chartData = [];
  double incomeTotal = 0.0;
  double expenseTotal = 0.0;
  double savingTotal = 0.0;

  String currencySymbol = '\$';
  final NumberFormat currencyFormat = NumberFormat('#,##0.00');

  final CurrencyDB _currencyDB = CurrencyDB();

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency();
    _loadTransactions(context);
  }


  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('FinancialReport')),
        // title: const Text(
        //   'Financial Report',
        //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        // ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            children: [
              buildBalanceSection(languageProvider),
              const SizedBox(height: 10),
              const Divider(
                height: 20.0,
                thickness: 3.0,
                color: Color.fromARGB(255, 17, 215, 119),
                indent: 25.0,
                endIndent: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageProvider.translate('balance'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   'balance',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  Text(
                    ' $currencySymbol ${currencyFormat.format(incomeTotal - expenseTotal)}',
                    style: TextStyle(
                      fontSize: 20,
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
            ],
          ),
        ),
      ),
    );
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
  Future<void> _loadTransactions(BuildContext context) async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final db = TransactionDB();
    final allTransactions = await db.getTransactions();

    Map<String, double> categoryTotals = {
      'Income': 0.0,
      'Expense': 0.0,
      'Saving': 0.0,
    };

    // Calculate total amount per(Income, Expense, Saving)
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
          languageProvider.translate('Income'),
          incomeTotal,
          const Color.fromARGB(255, 17, 215, 119),
        ),
        ChartData(
          languageProvider.translate('Expense'),
          expenseTotal,
          Colors.red.shade400,
        ),
        ChartData(
          languageProvider.translate('Saving'),
          savingTotal,
          Colors.orange.shade400,
        ),
      ];

      // chartData = [

      //   ChartData( languageProvider.translate('Income'), incomeTotal,
      //       const Color.fromARGB(255, 17, 215, 119)),
      //   //   'Income',
      //   //   incomeTotal,
      //   //   const Color.fromARGB(255, 17, 215, 119),
      //   // ),
      //   ChartData('Expense', expenseTotal, Colors.red.shade400),
      //   ChartData('Saving', savingTotal, Colors.orange.shade400),
      // ];
    });
  }
  // Modernized balance section
  Widget buildBalanceSection(LanguageProvider languageProvider) {
    return Column(
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildBalanceCard(languageProvider, 'Income', incomeTotal,
                const Color.fromARGB(255, 17, 215, 119), Icons.attach_money),
            buildBalanceCard(languageProvider, 'Expense', expenseTotal,
                Colors.red, Icons.money_off),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildsavingCard(languageProvider, 'Saving', savingTotal,
                Colors.orange, Icons.savings),
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
  Widget buildBalanceCard(LanguageProvider languageProvider, String title,
      double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: color,
          // gradient: LinearGradient(
          //   colors: [color.withOpacity(0.9), color.withOpacity(0.9)],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15),
            const SizedBox(height: 8),
            Text(
              languageProvider.translate(title),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol ${currencyFormat.format(amount)}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildsavingCard(LanguageProvider languageProvider, String title,
      double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          // gradient: LinearGradient(
          //
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15),
            const SizedBox(height: 8),
            Text(
              languageProvider.translate(title),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol ${currencyFormat.format(amount)}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 350,
        child: SfCircularChart(
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            overflowMode: LegendItemOverflowMode.wrap,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            iconHeight: 14,
            iconWidth: 14,
          ),
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.name,
              yValueMapper: (ChartData data, _) => data.amount,
              radius: '100%',
              innerRadius: '10%', // More distinct donut shape
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                connectorLineSettings: const ConnectorLineSettings(
                  type: ConnectorType.curve,
                  color: Colors.grey,
                  length: '20%',
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                builder: (data, point, series, pointIndex, seriesIndex) {
                  final formatter = NumberFormat.compactCurrency(
                    symbol: currencySymbol,
                    decimalDigits: 2,
                  );
                  return Column(
                    children: [
                      Text(
                        '${data.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatter.format(data.amount),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
              explode: true,
              explodeOffset: '2%',
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            color: Colors.white,
            borderColor: Colors.grey,
            borderWidth: 1,
            textStyle: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            header: '',
            format: 'point.x: ${currencySymbol}point.y',
          ),
        ),
      ),
    );
  }

// Donut chart widget
  // Widget _buildChart() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: SizedBox(
  //       height: 300,
  //       child: SfCircularChart(
  //         series: <CircularSeries>[
  //           DoughnutSeries<ChartData, String>(
  //             dataSource: chartData,
  //             pointColorMapper: (ChartData data, _) => data.color,
  //             xValueMapper: (ChartData data, _) => data.name,
  //             yValueMapper: (ChartData data, _) => data.amount,
  //             radius: '100%',
  //             innerRadius: '10%',
  //             dataLabelSettings: const DataLabelSettings(
  //               isVisible: true,
  //               textStyle: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             animationDuration: 2000,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
