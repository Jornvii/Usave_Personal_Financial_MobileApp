import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/main/report_screen.dart';
import 'package:flutter_chat_bot/screens/sub/addsaving_goal_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/currency_db.dart';
import '../../models/profile_db.dart';
import '../../models/transaction_db.dart';
import '../../provider/langguages_provider.dart';
import '../../widgets/edit_transaction.dart';
import '../../widgets/data_category.dart';
import '../../widgets/data_table.dart';
import '../../widgets/notiiiiiiii.dart';
import '../main/transactions_screen.dart';
import 'sub_calculate.dart';

class SubHomeScreen extends StatefulWidget {
  final List transactions;
  const SubHomeScreen({super.key, required this.transactions});

  @override
  State<SubHomeScreen> createState() => _SubHomeScreenState();
}

class _SubHomeScreenState extends State<SubHomeScreen> {
  String? _username;
  final UserDB _userDB = UserDB();
  List<Map<String, dynamic>> transactions = [];
  String currencySymbol = '\$';
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _startTransactionReload();
    _loadTransactions();
    _loadCurrency();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTransactions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // greeting text
  String _getGreetingMessage() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return languageProvider.translate('GoodMorning');
    } else if (hour < 18) {
      return languageProvider.translate('GoodAfternoon');
    } else {
      return languageProvider.translate('GoodEvening');
    }
  }

  void _startTransactionReload() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadTransactions();
    });
  }

// for notification is set timer  to load data and set reqirement if load data = true then generate notification
  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();
    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final theme = Theme.of(context);

    // Group transactions by date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactions) {
      final dateKey = transaction['date'];
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]?.add(transaction);
    }

    final sortedGroupedTransactions = groupedTransactions.entries.toList()
      ..sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _username == null || _username!.isEmpty
              ? GestureDetector(
                  onTap: () => _showEditDialog(languageProvider),
                  child: Row(
                    children: [
                      Text(
                        '${_getGreetingMessage()}, ',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        languageProvider.translate('Tapheretosetyourname'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Text(
                      '${_getGreetingMessage()}​,',
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      ' $_username',
                      style: theme.appBarTheme.titleTextStyle
                          ?.copyWith(color: Colors.green),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ],
                ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('Menu'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // GridView section
            Container(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final options = [
                    {
                      'icon': Icons.category,
                      'title': languageProvider.translate('DataCategory'),
                      'screen': const ListSummaryScreen(),
                      'color': Colors.red,
                    },
                    {
                      'icon': Icons.table_view,
                      'title': languageProvider.translate('DataTable'),
                      'screen': const DataTransactionTable(),
                      'color': Colors.green,
                    },
                    {
                      'icon': Icons.pie_chart,
                      'title': languageProvider.translate('Reports'),
                      'screen': const ReportScreen(),
                      'color': Colors.lime,
                    },

                    {
                      'icon': Icons.dashboard,
                      'title': languageProvider.translate('SavingGoal'),
                      'screen': const SavingGoalScreen(),
                      'color': Colors.orange,
                    },
                    // {
                    //   'icon': Icons.calculate,
                    //   'title': languageProvider.translate('Calculate'),
                    //   'screen': const CalculatorScreen(),
                    //   'color': Colors.blueGrey,
                    // },
                    {
                      'icon': Icons.add_circle,
                      'title': languageProvider.translate('Transactions'),
                      'screen': const TransactionsScreen(),
                      'color': Colors.lightBlue,
                    },
                    {
                      'icon': Icons.notifications,
                      'title': 'TIMER',
                      'screen':   TestNotificatioScreen(),
                      'color': Colors.black,
                    },
                    // {
                    //   'icon': Icons.currency_bitcoin,
                    //   'title': 'currency',
                    //   'screen':  CurrencyConverterScreen(),
                    //   'color': Colors.purple,
                    // },
                  ];

                  return _buildGridTile(
                    context,
                    languageProvider,
                    options[index]['icon'] as IconData,
                    options[index]['title'] as String,
                    options[index]['color'] as Color,
                    options[index]['screen'] as Widget,
                    theme,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Recent Transactions Section
            Text(
              languageProvider.translate('recent_transactions'),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: sortedGroupedTransactions.isEmpty
                  ? Center(
                      child: Text(
                        languageProvider.translate('Notransactionsavailable'),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedGroupedTransactions.length,
                      itemBuilder: (context, index) {
                        final date = sortedGroupedTransactions[index].key;
                        final dailyTransactions =
                            sortedGroupedTransactions[index].value;
                        dailyTransactions
                            .sort((a, b) => b['date'].compareTo(a['date']));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                date ==
                                        DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now())
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
                                        onPressed: (_) async {
                                          final updatedTransaction =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateTransactionScreen(
                                                transaction: transaction,
                                              ),
                                            ),
                                          );

                                          if (updatedTransaction != null) {
                                            final db = TransactionDB();
                                            await db.updateTransaction(
                                              updatedTransaction['id'],
                                              updatedTransaction,
                                            );
                                            _loadTransactions();
                                          }
                                        },
                                        backgroundColor: Colors.blue,
                                        icon: Icons.edit,
                                        // label: 'Edit',
                                      ),
                                      SlidableAction(
                                        onPressed: (_) =>
                                            _confirmDeleteTransaction(
                                                transaction['id']),
                                        backgroundColor: Colors.red,
                                        icon: Icons.delete,
                                        // label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      transaction['typeCategory'] == 'Income'
                                          ? Icons.arrow_upward
                                          : transaction['typeCategory'] ==
                                                  'Expense'
                                              ? Icons.arrow_downward
                                              : Icons.savings,
                                      color: transaction['typeCategory'] ==
                                              'Income'
                                          ? Colors.green
                                          : transaction['typeCategory'] ==
                                                  'Expense'
                                              ? Colors.red
                                              : const Color.fromARGB(
                                                  255, 255, 215, 0),
                                    ),
                                    title: Text(
                                      transaction['category'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15),
                                    ),
                                    trailing: Text(
                                      '$currencySymbol ${transaction['amount']}',
                                      // '$currencySymbol ${transaction['amount']}',
                                      style: TextStyle(
                                        color: transaction['typeCategory'] ==
                                                'Income'
                                            ? Colors.green
                                            : transaction['typeCategory'] ==
                                                    'Expense'
                                                ? Colors.red
                                                : const Color.fromARGB(
                                                    255, 255, 215, 0),
                                      ),
                                    ),
                                  ));
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCurrency() async {
    final db = CurrencyDB();
    final defaultCurrency = await db.getDefaultCurrency();
    setState(() {
      currencySymbol = defaultCurrency?['symbol'] ?? '\$';
    });
  }

  Future<void> _loadUserProfile() async {
    final userProfile = await _userDB.fetchUserProfile();
    if (userProfile != null) {
      setState(() {
        _username = userProfile['username'];
      });
    }
  }

  Future<void> _showEditDialog(LanguageProvider languageProvider) async {
    final TextEditingController usernameController =
        TextEditingController(text: _username);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('edit_user_name')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('username'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUsername = usernameController.text.trim();
                await _userDB.saveOrUpdateUserProfile(updatedUsername);
                await _loadUserProfile();
                setState(() {
                  _username = updatedUsername;
                });

                Navigator.of(context).pop();
                _showSuccessSnackbar(languageProvider);
              },
              child: Text(languageProvider.translate('save')),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackbar(LanguageProvider languageProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageProvider.translate('profile_updated')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDeleteTransaction(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Trash?'),
        content: const Text('This will move the transaction to Trashbin ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = TransactionDB();
              await db.moveToTrash(id);
              Navigator.pop(context);
              _loadTransactions();
            },
            child: const Text('Move', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(
      BuildContext context,
      LanguageProvider languageProvider,
      IconData icon,
      String title,
      Color color,
      Widget destination,
      ThemeData theme) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              languageProvider.translate(title),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
