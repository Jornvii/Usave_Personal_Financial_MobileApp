import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const UpdateTransactionScreen({super.key, required this.transaction});

  @override
  _UpdateTransactionScreenState createState() =>
      _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState extends State<UpdateTransactionScreen> {
  late String typeCategory;
  String? selectedCategory;
  DateTime? transactionDate;
  late TextEditingController amountController;
  late TextEditingController descriptionController;

  List<String> incomeCategories = [];
  List<String> expenseCategories = [];
  List<String> savingCategories = [];

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
  final List<String> defaultSavingCategories = [
    'Emergency Fund',
    'Retirement',
    'Investments',
    'Vacation Fund',
  ];

  @override
  void initState() {
    super.initState();
    typeCategory = widget.transaction['typeCategory'];
    selectedCategory = widget.transaction['category'];
    transactionDate = DateTime.parse(widget.transaction['date']);
    amountController = TextEditingController(
      text: widget.transaction['amount'].toString(),
    );
    descriptionController = TextEditingController(
      text: widget.transaction['description'],
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      incomeCategories = defaultIncomeCategories;
      expenseCategories = defaultExpenseCategories;
      savingCategories = defaultSavingCategories;
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

  void _updateTransaction() {
    if (amountController.text.isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final updatedTransaction = {
      'id': widget.transaction['id'],
      'typeCategory': typeCategory,
      'category': selectedCategory!,
      'amount': double.parse(amountController.text),
      'description': descriptionController.text,
      'date': DateFormat('yyyy-MM-dd').format(transactionDate!),
    };

    Navigator.pop(context, updatedTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TypeCategory Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Income', 'Expense', 'Saving'].map((type) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      typeCategory = type;
                      selectedCategory = null; // Reset category
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: typeCategory == type
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      type,
                      style: TextStyle(
                        color:
                            typeCategory == type ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Amount Input
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: (typeCategory == 'Income'
                      ? incomeCategories
                      : typeCategory == 'Expense'
                          ? expenseCategories
                          : savingCategories)
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Date Picker
            TextFormField(
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: 'Transaction Date',
                hintText: transactionDate != null
                    ? DateFormat('yyyy-MM-dd').format(transactionDate!)
                    : 'Pick a date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Description Input
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _updateTransaction,
              child: const Text('Update Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
