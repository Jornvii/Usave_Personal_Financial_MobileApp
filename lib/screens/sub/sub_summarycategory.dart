import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/currency_db.dart';
import '../../models/transaction_db.dart';
import '../../provider/langguages_provider.dart';

class ReportCategoryScreen extends StatefulWidget {
  const ReportCategoryScreen({super.key});

  @override
  _ReportCategoryScreenState createState() => _ReportCategoryScreenState();
}

class _ReportCategoryScreenState extends State<ReportCategoryScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> transactions = [];
  String currencySymbol = '\$';
  String selectedFilter = 'Income';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _loadTransactions();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _loadCurrency() async {
    final db = CurrencyDB();
    final defaultCurrency = await db.getDefaultCurrency();
    setState(() {
      currencySymbol = defaultCurrency?['symbol'] ?? '\$';
    });
  }

  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();
    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);
    });
  }

  List<ChartData> _getChartData(String filter) {
    Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction['typeCategory'] == filter) {
        String category = transaction['category'];
        double amount = transaction['amount'];
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
    }

    return categoryTotals.entries
        .map((entry){
          print(">>>>> ${entry.key } ${entry.key.hashCode}");

          return ChartData(entry.key, entry.value,Color((entry.key.hashCode+1000)*0xFFFFFF));}
                    // return ChartData(entry.key, entry.value, _getCategoryColor(entry.key));}
// 
        )
        .toList();
  }

  Color _getCategoryColor(String category) {
    // Optimized color selection
    final List<Color> colorPalette = [
      Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple, Colors.yellow,
      Colors.teal, Colors.cyan, Colors.indigo, Colors.pink
    ];
    print("color>>>> ${category.hashCode % colorPalette.length}");
    return colorPalette[category.hashCode % colorPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(languageProvider.translate('ReportbyCategory'))),
    
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              selectedFilter = ['Income', 'Expense', 'Saving'][index];
            });
          },
          indicatorColor: Colors.blueAccent,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: [
            Tab(text: languageProvider.translate('Income')),
            Tab(text: languageProvider.translate('Expense')),
            Tab(text: languageProvider.translate('Saving')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('Income'),
          _buildTabContent('Expense'),
          _buildTabContent('Saving'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String category) {
    final chartData = _getChartData(category);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _buildChart(chartData),
          Expanded(child: _buildCategoryList(chartData)),
        ],
      ),
    );
  }

 Widget _buildChart(List<ChartData> chartData) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: SizedBox(
      height: 380,
      child: SfCircularChart(
        legend: const Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            overflowMode: LegendItemOverflowMode.wrap,
            
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            iconHeight: 15,
            iconWidth: 15,
          ),
        series: <CircularSeries<ChartData, String>>[
          DoughnutSeries<ChartData, String>(
            dataSource: chartData,
            pointColorMapper: (ChartData data, _) => data.color,
            xValueMapper: (ChartData data, _) => data.name,
            yValueMapper: (ChartData data, _) => data.amount,
            radius: '105%',
            innerRadius: '35%',
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
              strokeColor: const Color.fromARGB(255, 71, 69, 69),
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
// inner  amount show in chart 

//  Widget _buildChart(List<ChartData> chartData) {
//   return Padding(
//     padding: const EdgeInsets.all(12.0),
//     child: SizedBox(
//       height: 380,
//       child: SfCircularChart(
//         legend: const Legend(
//             isVisible: true,
//             position: LegendPosition.bottom,
//             overflowMode: LegendItemOverflowMode.wrap,
//             textStyle: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//             iconHeight: 14,
//             iconWidth: 14,
//           ),
//         series: <CircularSeries<ChartData, String>>[
//           DoughnutSeries<ChartData, String>(
//             dataSource: chartData,
//             pointColorMapper: (ChartData data, _) => data.color,
//             xValueMapper: (ChartData data, _) => data.name,
//             yValueMapper: (ChartData data, _) => data.amount,
//             radius: '105%',
//             innerRadius: '35%',
//             dataLabelSettings: const DataLabelSettings(
//               isVisible: true,
//               labelPosition: ChartDataLabelPosition.inside,
//               textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
//             ),
//              explode: true,
//               explodeOffset: '2%',
//               strokeWidth: 2,
//               strokeColor: const Color.fromARGB(255, 71, 69, 69),
//           ),
//         ],
//       ),
//     ),
//   );
// }


  Widget _buildCategoryList(List<ChartData> chartData) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: chartData.length,
      itemBuilder: (context, index) {
        final data = chartData[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: data.color, radius: 12),
            title: Text(data.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              NumberFormat.currency(symbol: currencySymbol).format(data.amount),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}

class ChartData {
  final String name;
  final double amount;
  final Color color;
  ChartData(this.name, this.amount, this.color);
}


