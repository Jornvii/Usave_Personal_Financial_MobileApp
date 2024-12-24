import 'package:flutter/material.dart';
import '../models/category_db.dart';
import '../models/saving_goaldb.dart';

class SavingGoalScreen extends StatefulWidget {
  const SavingGoalScreen({super.key});

  @override
  _SavingGoalScreenState createState() => _SavingGoalScreenState();
}

class _SavingGoalScreenState extends State<SavingGoalScreen> {
  final List<String> defaultSavingCategories = [
    'Emergency Fund',
    'Healthcare',
    'Travel',
    'Debt Reduction',
  ];

  List<String> dynamicCategories = [];
  Map<String, double?> categoryGoals = {};

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndGoals();
  }

  Future<void> _loadCategoriesAndGoals() async {
    final dynamicSavingCategories =
        await CategoryDB().fetchCategoriesByType('Saving');
    final allCategories = [
      ...defaultSavingCategories,
      ...dynamicSavingCategories.map((category) => category['name'] as String),
    ];

    final goals = await SavingGoalDB().fetchSavingGoals();

    setState(() {
      categoryGoals = {
        for (var category in allCategories)
          category: goals.firstWhere(
            (goal) => goal['savingCategory'] == category,
            orElse: () => {'goalAmount': null},
          )['goalAmount'] as double?,
      };
    });
  }

  void _showAddGoalDialog(String category) {
    final TextEditingController goalController = TextEditingController(
      text: categoryGoals[category]?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Set Goal for $category',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: goalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Goal Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final goalAmount = double.tryParse(goalController.text) ?? 0.0;
                await SavingGoalDB().saveSavingGoal(category, goalAmount);
                Navigator.pop(context);
                _loadCategoriesAndGoals();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSavingGoalDialog() {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Add New Saving Goal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Saving Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Goal Amount',
                  border: OutlineInputBorder(),
                ),
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
                final category = categoryController.text.trim();
                final goalAmount = double.tryParse(goalController.text) ?? 0.0;

                if (category.isNotEmpty) {
                  await CategoryDB().insertCategory({
                    'name': category,
                    'type': 'Saving',
                  });
                  await SavingGoalDB().saveSavingGoal(category, goalAmount);
                  Navigator.pop(context);
                  _loadCategoriesAndGoals();
                }
              },
              child: const Text('Add'),
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
        title: const Text('Saving Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategoriesAndGoals,
          ),
        ],
      ),
      body: categoryGoals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: categoryGoals.length,
                itemBuilder: (context, index) {
                  final category = categoryGoals.keys.elementAt(index);
                  final goalAmount = categoryGoals[category];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        goalAmount != null
                            ? 'Goal: \$${goalAmount.toStringAsFixed(2)}'
                            : 'No goal set yet', // Default message for unset goals
                        style: TextStyle(
                            color: goalAmount != null
                                ? Colors.greenAccent
                                : Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddGoalDialog(category),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSavingGoalDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
