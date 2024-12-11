import 'package:flutter/material.dart';

class UpdateTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const UpdateTransactionScreen({super.key, required this.transaction});

  @override
  _UpdateTransactionScreenState createState() =>
      _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState extends State<UpdateTransactionScreen> {
  String typeCategory = 'Income';
  String? selectedCategory; // Make this nullable
  List<String> incomeCategories = ['Salary', 'Business'];
  List<String> expenseCategories = ['Food', 'Rent', 'Entertainment'];
  List<String> savingCategories = ['Savings', 'Investments'];

  @override
  void initState() {
    super.initState();
    typeCategory = widget.transaction['typeCategory'];
    selectedCategory = widget.transaction['category'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for TypeCategory
            DropdownButtonFormField<String>(
              value: typeCategory,
              items: ['Income', 'Expense', 'Saving']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  typeCategory = value!;
                  selectedCategory = null; // Reset category when typeCategory changes
                });
              },
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown for Category
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
          ],
        ),
      ),
    );
  }
}
