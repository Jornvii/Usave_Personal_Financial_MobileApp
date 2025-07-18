import 'package:flutter/material.dart';
import '../models/currency_db.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyDB _currencyDB = CurrencyDB();
  List<Map<String, dynamic>> currencies = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    final data = await _currencyDB.getCurrencies();
    setState(() {
      currencies = data;
    });
  }

  // Future<void> _addCurrency() async {
  //   final name = _nameController.text;
  //   final symbol = _symbolController.text;

  //   if (name.isNotEmpty && symbol.isNotEmpty) {
  //     await _currencyDB.insertCurrency(name, symbol);
  //     _nameController.clear();
  //     _symbolController.clear();
  //     _loadCurrencies();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Currency added successfully')),
  //     );
  //   }
  // }

  // Add this method to handle adding currencies incase of duplicates and empty fields
  Future<void> _addCurrency() async {
    final name = _nameController.text.trim();
    final symbol = _symbolController.text.trim();

    if (name.isEmpty || symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    // Check for duplicates in SQLite
    final exists = await _currencyDB.isCurrencyExist(name, symbol);
    if (exists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Duplicate Currency'),
          content: const Text(
            'A currency with the same name or symbol already exists.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Insert the currency if no duplicates
    await _currencyDB.insertCurrency(name, symbol);
    _nameController.clear();
    _symbolController.clear();
    _loadCurrencies();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Currency added successfully')),
    );
  }

  Future<void> _setDefaultCurrency(int id, String symbol) async {
    await _currencyDB.setDefaultCurrency(id);
    _loadCurrencies();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Default currency set to $symbol')),
    );
  }

  Future<void> _deleteCurrency(int id) async {
    await _currencyDB.deleteCurrency(id); // Add this method in CurrencyDB
    _loadCurrencies();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Currency deleted successfully')),
    );
  }
void _alertDailogCurrencies() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 10),
            Text('Currency Restriction',style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),
          ],
        ),
        content: const Text(
          'You can use only one currency the default currency. Let add and set if you want use Your own currency below.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Currencies'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: _alertDailogCurrencies,
              icon: const Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Currency Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _symbolController,
                  decoration:
                      const InputDecoration(labelText: 'Symbol like \$'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addCurrency,
                  child: const Text('Add Currency'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isDefault = currency['isDefault'] == 1;

                return Dismissible(
                  key: Key(currency['id'].toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (isDefault) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot delete the default currency.'),
                        ),
                      );
                      return false; // Prevent dismissal
                    }

                    // Show confirmation dialog
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Currency'),
                          content: Text(
                            'Are you sure you want to delete ${currency['name']} (${currency['symbol']})?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );

                    return result == true; // Delete only if user confirms
                  },
                  onDismissed: (direction) {
                    _deleteCurrency(currency['id']);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text('${currency['name']} (${currency['symbol']})'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDefault
                            ? Theme.of(context).primaryColor.withOpacity(0.5)
                            : null,
                      ),
                      onPressed: () => _setDefaultCurrency(
                          currency['id'], currency['symbol']),
                      child: Text(isDefault ? 'Default' : 'Set as Default'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
