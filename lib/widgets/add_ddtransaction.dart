import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category_db.dart';

class AddTransactionScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddTransactionScreen({super.key, required this.selectedDate});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isIncome = true;
  bool hasTransactionBeenAdded = false;
  String selectedCategory = '';
  DateTime? transactionDate;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<String> incomeCategories = []; // Will store Income categories
  List<String> expenseCategories = []; // Will store Expense categories

  // Default categories
  final List<String> defaultIncomeCategories = [
    'Interests',
    'Sales',
    'Bonus',
    'Salary',
  ];
  final List<String> defaultExpenseCategories = [
    'Miscellaneous',
    'Childcare',
    'Business Expense',
    'Travel',
    'Taxes',
    'Gifts and Donations',
    'Personal Care',
    'Education',
    'Insurances',
    'Healthcare',
    'Transportation',
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories from the database and merge with default categories
  Future<void> _loadCategories() async {
    final db = CategoryDB();
    final allCategories = await db.getCategories();

    setState(() {
      // Combine default categories with those fetched from the database
      incomeCategories = [
        ...defaultIncomeCategories,
        ...allCategories
            .where((cat) => cat['type'] == 'Income')
            .map((cat) => cat['name'] as String)
            .toList()
      ];

      expenseCategories = [
        ...defaultExpenseCategories,
        ...allCategories
            .where((cat) => cat['type'] == 'Expense')
            .map((cat) => cat['name'] as String)
            .toList()
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
        'isIncome': isIncome,
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

  void _handleToggle(bool incomeSelected) {
    if (isIncome != incomeSelected && !hasTransactionBeenAdded) {
      setState(() {
        isIncome = incomeSelected;
        _resetFields(); // Reset fields only if no transaction has been added
      });
    } else {
      setState(() {
        isIncome = incomeSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Toggle for Income/Expense
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _handleToggle(true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isIncome ? Colors.redAccent : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: isIncome ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _handleToggle(false),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              !isIncome ? Colors.redAccent : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: !isIncome ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Amount Field
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: const Text('Select Category'),
                  isExpanded: true,
                  items: (isIncome ? incomeCategories : expenseCategories)
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
                      return 'Category is required';
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
                    labelText: 'Date of Transaction',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: transactionDate == null
                        ? 'Select a date'
                        : DateFormat('yyyy-MM-dd').format(transactionDate!),
                  ),
                  validator: (value) {
                    if (transactionDate == null) {
                      return 'Date is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description Field
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter any notes or details (optional)',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                // Add Transaction Button
                ElevatedButton(
                  onPressed: _addTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
