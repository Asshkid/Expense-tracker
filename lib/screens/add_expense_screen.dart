import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final amount = TextEditingController();

  String selectedCategory = "General";

  bool isEdit = false;
  int? editIndex;
  DateTime selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map && !isEdit) {

      // ✏ EDIT MODE
      if (args['expense'] != null) {
        final expense = args['expense'] as Expense;
        editIndex = args['index'];

        title.text = expense.title;
        amount.text = expense.amount.toString();
        selectedCategory = expense.category;
        selectedDate = expense.date;

        isEdit = true;
      }

      // 📅 CREATE FROM CALENDAR
      if (args['date'] != null) {
        selectedDate = args['date'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Expense" : "Add Expense"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) =>
                v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (v) =>
                v == null || v.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 10),

              DropdownButton<String>(
                value: selectedCategory,
                items: ["General", "Food", "Transport", "Shopping", "Bills"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (v) {
                  setState(() => selectedCategory = v!);
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  final expense = Expense(
                    title: title.text,
                    amount: double.parse(amount.text),
                    category: selectedCategory,
                    date: selectedDate,
                  );

                  if (isEdit) {
                    provider.updateExpense(editIndex!, expense);
                  } else {
                    provider.addExpense(expense);
                  }

                  Navigator.pop(context);
                },
                child: Text(isEdit ? "Update" : "Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}