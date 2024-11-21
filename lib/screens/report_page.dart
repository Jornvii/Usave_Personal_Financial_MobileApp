// screens/report_tab.dart
import 'package:flutter/material.dart';
import '../models/financial_data.dart';

class ReportScreen  extends StatelessWidget {
  final FinancialData? data;
  final String? plan;

  const ReportScreen ({this.data, this.plan, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: data != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Income: ${data!.income}"),
                Text("Expenses: ${data!.expenses}"),
                Text("Savings Goal: ${data!.savingsGoal}"),
                const SizedBox(height: 20),
                Text("Plan: $plan"),
              ],
            )
          : const Text("No financial data available."),
    );
  }
}
