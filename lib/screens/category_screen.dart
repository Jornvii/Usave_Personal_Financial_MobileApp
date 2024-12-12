import 'package:flutter/material.dart';
import '../models/category_db.dart';
import '../widgets/add_currency.dart';

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
  final List<String> defaultSavingCayegories = [
    'Emergency Fund',
    'Healthcare',
    'Travel',
    'Debt Reduction'
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
  List<Map<String, dynamic>> savingCategories = [];
  List<Map<String, dynamic>> expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<Map<String, dynamic>> categories = await CategoryDB().getCategories();
    List<Map<String, dynamic>> income = [];
    List<Map<String, dynamic>> expense = [];
    List<Map<String, dynamic>> saving = [];

    for (var category in categories) {
      if (category['type'] == 'Income') {
        income.add(category);
      } else if (category['type'] == 'Expense') {
        expense.add(category);
      } else if (category['type'] == 'Saving') {
        saving.add(category);
      }
    }

    setState(() {
      incomeCategories = income;
      expenseCategories = expense;
      savingCategories = saving;
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(137, 158, 158, 158),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                       boxShadow: [
            BoxShadow(
              color:  Color.fromARGB(137, 158, 158, 158),
              blurRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],),
                  child: ListTile(
                    leading: const Icon(Icons.paid),
                    title: const Text('Currency'),
                    // subtitle: const Text('Currency'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CurrencyScreen()),
                      );
                    },
                  ),
                ),
              ),
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
              const SizedBox(height: 20),
              _buildCategorySection(
                title: 'Saving Categories',
                categories: defaultSavingCayegories,
                newCategories: savingCategories,
                color: Colors.yellow,
                type: 'Saving',
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
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Category'),
                              content: const Text(
                                  'Are you sure you want to delete this category?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        _deleteCategory(category);
                      },
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

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();
    String selectedType = 'Income';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Category Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: ['Income', 'Expense', 'Saving']
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedType = value!;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final newCategory = categoryController.text.trim();
                        if (newCategory.isNotEmpty) {
                          await CategoryDB().insertCategory({
                            'name': newCategory,
                            'type': selectedType,
                          });
                          _loadCategories();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCategory(Map<String, dynamic> category) async {
    await CategoryDB().deleteCategory(category['id']);
    _loadCategories();
  }

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
                items: ['Income', 'Expense', 'Saving']
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
                  _loadCategories();
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
