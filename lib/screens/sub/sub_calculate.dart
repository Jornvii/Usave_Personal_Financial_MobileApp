import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/currency_db.dart';
import '../../provider/langguages_provider.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestrateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  String currencySymbol = '\$';

  String? _resultDescription;
  final _formKey = GlobalKey<FormState>();
  Future<void> _loadCurrency() async {
    final db = CurrencyDB();
    final defaultCurrency = await db.getDefaultCurrency();
    setState(() {
      currencySymbol = defaultCurrency?['symbol'] ?? '\$';
    });
  }

  void _calculateResult() {
    if (_formKey.currentState?.validate() ?? false) {
      final double? amount = double.tryParse(_amountController.text);
      final double interestrate =
          double.tryParse(_interestrateController.text) ?? 0;
      final int years = int.tryParse(_yearsController.text) ?? 0;
      final int months = int.tryParse(_monthsController.text) ?? 0;
      final int days = int.tryParse(_daysController.text) ?? 0;

      final int totalDays = (years * 365) + (months * 30) + days;

      if (amount == null && totalDays == 0) {
        setState(() {
          _resultDescription = 'Please enter either an Amount or a Duration.';
        });
        return;
      }

      double total = 0;
      double interestvalue = 0;

      if (amount != null) {
        if (interestrate > 0) {
          // With interest rate
          total = amount * (1 + (interestrate / 100) * (totalDays / 365));
          interestvalue = total - amount;
        } else {
          // No interest rate
          total = amount * totalDays;
        }
      }

      setState(() {
        _loadCurrency();
        if (interestrate > 0) {
          _resultDescription =
              'Based on your input:\n\n• Amount: ${amount != null ? '${amount.toStringAsFixed(2)} $currencySymbol' : 'Not provided'}\n'
              '• interestRate: $interestrate %\n'
              '• Duration: ${years > 0 ? '$years year(s)' : ''} ${months > 0 ? '$months month(s)' : ''} ${days > 0 ? '$days day(s)' : ''}\n\n'
              'This means if you save ${amount?.toStringAsFixed(2)}$currencySymbol for a period of ${years > 0 ? '$years year(s)' : ''} ${months > 0 ? '$months month(s)' : ''} ${days > 0 ? '$days day(s)' : ''}, '
              'you will got interest amount ${interestvalue.toStringAsFixed(2)}  $currencySymbol  your total amount, including interest, will be ${total.toStringAsFixed(2)}.\n\n'
              'This includes your initial savings and the calculated interest based on the interestrate provided.';
        } else {
          _resultDescription =
              'Based on your input:\n\n• Amount: ${amount != null ? '${amount.toStringAsFixed(2)} $currencySymbol' : 'Not provided'}\n'
              '• Duration: ${years > 0 ? '$years year(s)' : ''} ${months > 0 ? '$months month(s)' : ''} ${days > 0 ? '$days day(s)' : ''}\n\n'
              'This means if you save ${amount?.toStringAsFixed(2)} $currencySymbol everyday for ${years > 0 ? '$years year(s)' : ''} ${months > 0 ? '$months month(s)' : ''} ${days > 0 ? '$days day(s)' : ''}, '
              'you will accumulate a total of ${total.toStringAsFixed(2)}  $currencySymbol. This total is based solely on your initial amount and the specified duration';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isEmpty &&
                      _yearsController.text.isEmpty &&
                      _monthsController.text.isEmpty &&
                      _daysController.text.isEmpty) {
                    return 'Amount or Duration (Year, Month, Days) is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _interestrateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'interestRate (%)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Years',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => _validateDuration(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _monthsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Months',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => _validateDuration(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => _validateDuration(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: FloatingActionButton.extended(
                    onPressed: _calculateResult,
                    label: Text(languageProvider.translate("Calculate")),
                    icon: const Icon(Icons.calculate),
                    backgroundColor: const Color.fromARGB(255, 17, 215, 119),
                  ),
                ),
              ),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: _calculateResult,
              //     child: const Text('Calculate'),
              //   ),
              // ),
              const SizedBox(height: 20),
              if (_resultDescription != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: SelectableText.rich(
                        TextSpan(
                          children:
                              _parseResultDescription(_resultDescription!),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _parseResultDescription(String description) {
    final RegExp numberRegex =
        RegExp(r'\d+(\.\d+)?'); // Matches integers or decimals
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    final matches = numberRegex.allMatches(description);
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: description.substring(lastIndex, match.start),
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
        ));
      }

      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < description.length) {
      spans.add(TextSpan(
        text: description.substring(lastIndex),
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ));
    }

    return spans;
  }

  String? _validateDuration() {
    if (_yearsController.text.isEmpty &&
        _monthsController.text.isEmpty &&
        _daysController.text.isEmpty) {
      return 'At least one of Years, Months, or Days is required.';
    }
    return null;
  }
}
