import 'package:flutter/material.dart';
import '../models/category_db.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> defaultIncomeCategories = [
    'Interests',
    'Sales',
    'Bonus',
    'Salary'
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

  List<Map<String, dynamic>> incomeCategories = [];
  List<Map<String, dynamic>> expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories from the database
  Future<void> _loadCategories() async {
    List<Map<String, dynamic>> categories = await CategoryDB().getCategories();
    List<Map<String, dynamic>> income = [];
    List<Map<String, dynamic>> expense = [];

    // Separate default and new categories
    for (var category in categories) {
      if (category['type'] == 'Income') {
        income.add(category);
      } else {
        expense.add(category);
      }
    }

    setState(() {
      incomeCategories = income;
      expenseCategories = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySection(
                title: 'Income Categories',
                categories: defaultIncomeCategories,
                newCategories: incomeCategories,
                color: Colors.green,
                type: 'Income',
              ),
              const SizedBox(height: 20),
              _buildCategorySection(
                title: 'Expense Categories',
                categories: defaultExpenseCategories,
                newCategories: expenseCategories,
                color: Colors.red,
                type: 'Expense',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: const Color.fromARGB(255, 17, 215, 119),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required List<String> categories,
    required List<Map<String, dynamic>> newCategories,
    required Color color,
    required String type,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                ...categories.map((category) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            category,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )),
                ...newCategories.map((category) => Dismissible(
                      key: Key(category['id'].toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _deleteCategory(category),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.circle,
                            size: 8, color: Colors.grey),
                        title: Text(category['name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showEditCategoryDialog(context, category),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog to add new category
  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();
    String selectedType = 'Income'; // Default selection

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Category Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Income', 'Expense']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  await CategoryDB().insertCategory({
                    'name': newCategory,
                    'type': selectedType,
                  });
                  _loadCategories(); // Refresh the list
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Delete category with confirmation dialog
  void _deleteCategory(Map<String, dynamic> category) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await CategoryDB().deleteCategory(category['id']);
                _loadCategories(); // Refresh the list
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to edit category
  void _showEditCategoryDialog(
      BuildContext context, Map<String, dynamic> category) {
    final TextEditingController categoryController =
        TextEditingController(text: category['name']);
    String selectedType = category['type'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Category Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Income', 'Expense']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedCategory = categoryController.text.trim();
                if (updatedCategory.isNotEmpty) {
                  await CategoryDB().updateCategory(category['id'], {
                    'name': updatedCategory,
                    'type': selectedType,
                  });
                  _loadCategories(); // Refresh the list
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
