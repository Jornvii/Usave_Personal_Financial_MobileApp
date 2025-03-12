import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/provider/langguages_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_db.dart';

class AddTransactionScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddTransactionScreen({super.key, required this.selectedDate});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String typeCategory = 'Income';
  bool hasTransactionBeenAdded = false;
  String selectedCategory = '';
  DateTime? transactionDate;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<String> incomeCategories = [];
  List<String> expenseCategories = [];
  List<String> savingCategories = [];

  // Default categories
  final List<String> defaultIncomeCategories = [
    'Interests',
    'Sales',
    'Bonus',
    'Salary',
  ];
  final List<String> defaultExpenseCategories = [
    'Food and Drinks',
    'Gifts and Donations',
    'Transportation',
  ];
  final List<String> defaultSavingCategories = [
    'Emergency Fund',
    'Investments',
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('add_transaction')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Toggle for Income/Expense/Saving
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _handleToggle('Income'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: typeCategory == 'Income'
                                ? const Color.fromARGB(255, 0, 255, 8)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            languageProvider.translate('Income'),
                            style: TextStyle(
                              color: typeCategory == 'Income'
                                  ? Colors.black87
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _handleToggle('Expense'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: typeCategory == 'Expense'
                                ? const Color.fromARGB(255, 244, 26, 11)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            languageProvider.translate('Expense'),
                            style: TextStyle(
                              color: typeCategory == 'Expense'
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _handleToggle('Saving'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: typeCategory == 'Saving'
                                ? const Color.fromARGB(255, 255, 160, 18)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            languageProvider.translate('Saving'),
                            style: TextStyle(
                              color: typeCategory == 'Saving'
                                  ? Colors.black87
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Field
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('Amount'),
                    hintText: languageProvider.translate('Enteramount'),
                    prefixIcon: const Icon(Icons.payment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.translate('Amountisrequired');
                    }
                    if (double.tryParse(value) == null) {
                      return languageProvider.translate('Enteravalidnumber');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('Category'),
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: Text(languageProvider.translate('SelectCategory')),
                  isExpanded: true,
                  items: (typeCategory == 'Income'
                          ? incomeCategories
                          : typeCategory == 'Expense'
                              ? expenseCategories
                              : savingCategories)
                      .map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.translate('Categoryisrequired');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date Picker
                TextFormField(
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('DateofTransaction'),
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: transactionDate == null
                        ? languageProvider.translate('Selectadate')
                        : DateFormat('yyyy-MM-dd').format(transactionDate!),
                  ),
                  validator: (value) {
                    if (transactionDate == null) {
                      return languageProvider.translate('Dateisrequired');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description Field
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('Description'),
                    hintText:
                        languageProvider.translate('Enteranynotesordetails'),
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 40),

                // Add Transaction Button

                // ElevatedButton(
                //   onPressed: _addTransaction,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color.fromARGB(255, 52, 214, 136),
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 32, vertical: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: const Text(
                //     'Add Transaction',
                //     style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.black),
                //   ),
                // ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: FloatingActionButton.extended(
                    onPressed: _addTransaction,
                    label: Text(languageProvider.translate("AddTransaction")),
                    icon: const Icon(Icons.add),
                    backgroundColor: const Color.fromARGB(255, 17, 215, 119),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
    // Load categories from the database and merge with default categories
  Future<void> _loadCategories() async {
    final db = CategoryDB();
    final allCategories = await db.getCategories();

    setState(() {
      incomeCategories = [
        ...defaultIncomeCategories,
        ...allCategories
            .where((cat) => cat['type'] == 'Income')
            .map((cat) => cat['name'] as String),
      ];

      expenseCategories = [
        ...defaultExpenseCategories,
        ...allCategories
            .where((cat) => cat['type'] == 'Expense')
            .map((cat) => cat['name'] as String),
      ];

      savingCategories = [
        ...defaultSavingCategories,
        ...allCategories
            .where((cat) => cat['type'] == 'Saving')
            .map((cat) => cat['name'] as String),
      ];
    });
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: transactionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        transactionDate = pickedDate;
      });
    }
  }

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      if (transactionDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date for the transaction'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final newTransaction = {
        'category': selectedCategory,
        'amount': double.parse(amountController.text),
        'typeCategory': typeCategory,
        'description': descriptionController.text,
        'date': transactionDate,
      };

      setState(() {
        hasTransactionBeenAdded = true;
      });

      Navigator.pop(context, newTransaction);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _resetFields() {
    selectedCategory = '';
    transactionDate = null;
    amountController.clear();
    descriptionController.clear();
  }

  void _handleToggle(String selectedType) {
    if (typeCategory != selectedType && !hasTransactionBeenAdded) {
      setState(() {
        typeCategory = selectedType;
        _resetFields(); // Reset fields only if no transaction has been added
      });
    } else {
      setState(() {
        typeCategory = selectedType;
      });
    }
  }

}
