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

  Future<void> _addCurrency() async {
    final name = _nameController.text;
    final symbol = _symbolController.text;

    if (name.isNotEmpty && symbol.isNotEmpty) {
      await _currencyDB.insertCurrency(name, symbol);
      _nameController.clear();
      _symbolController.clear();
      _loadCurrencies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Currency added successfully')),
      );
    }
  }

  Future<void> _setDefaultCurrency(int id, String symbol) async {
    await _currencyDB.setDefaultCurrency(id);
    _loadCurrencies();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Default currency set to $symbol')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Currencies'),
        centerTitle: true,
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
                TextField(
                  controller: _symbolController,
                  decoration:
                      const InputDecoration(labelText: 'Symbol like \$  ฿...'),
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
                return ListTile(
                  title: Text('${currency['name']} (${currency['symbol']})'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDefault
                          ? const Color.fromARGB(255, 177, 222, 179)
                          : null,
                    ),
                    onPressed: () =>
                        _setDefaultCurrency(currency['id'], currency['symbol']),
                    child: Text(isDefault ? 'Default' : 'Set as Default'),
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
