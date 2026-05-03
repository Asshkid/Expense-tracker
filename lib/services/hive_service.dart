import 'package:hive/hive.dart';
import '../models/expense.dart';

class HiveService {
  static final box = Hive.box<Expense>('expenses');

  static List<Expense> getExpenses() {
    return box.values.toList();
  }

  static void addExpense(Expense expense) {
    box.add(expense);
  }
}