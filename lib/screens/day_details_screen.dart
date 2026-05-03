import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class DayDetailsScreen extends StatelessWidget {
  final DateTime date;

  const DayDetailsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    final dayExpenses = provider.expenses.where((e) =>
    e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${date.day}.${date.month}.${date.year}"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(),
              settings: RouteSettings(arguments: {
                'date': date, 
              }),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: dayExpenses.isEmpty
          ? const Center(child: Text("No expenses for this day 😴"))
          : ListView.builder(
        itemCount: dayExpenses.length,
        itemBuilder: (context, index) {
          final e = dayExpenses[index];

          return ListTile(
            title: Text(e.title),
            subtitle: Text(e.category),
            trailing: Text("- \$${e.amount}"),

            onTap: () {
              Navigator.pushNamed(
                context,
                '/add',
                arguments: {
                  'expense': e,
                  'index': provider.expenses.indexOf(e),
                },
              );
            },

            onLongPress: () {
              final i = provider.expenses.indexOf(e);
              provider.deleteExpense(i);
            },
          );
        },
      ),
    );
  }
}
