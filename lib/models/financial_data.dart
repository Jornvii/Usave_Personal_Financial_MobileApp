// models/financial_data.dart
class FinancialData {
  double income;
  double expenses;
  double savingsGoal;

  FinancialData({
    required this.income,
    required this.expenses,
    required this.savingsGoal,
  });

  double calculateSavings() => income - expenses;
}

///note to calculate for bot 