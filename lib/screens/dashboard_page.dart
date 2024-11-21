// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/financial_data.dart';

class DashboardScreen extends StatelessWidget {
  final FinancialData? financialData;

  const DashboardScreen({this.financialData, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: financialData != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text("Income: \$${financialData!.income}"),
                          Text("Expenses: \$${financialData!.expenses}"),
                          Text("Savings Goal: \$${financialData!.savingsGoal}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/report');
                    },
                    child: const Text("View Detailed Report"),
                  ),
                ],
              ),
            )
          : const Center(child: Text("No financial data available.")),
    );
  }
}
