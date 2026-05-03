import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

enum FilterType { day, month, year, all }

class ExpenseProvider extends ChangeNotifier {
  late Box<Expense> box;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  FilterType _filter = FilterType.day;
  FilterType get filter => _filter;

  //  CURRENCY
  bool isUzs = false;
  double _rate = 12500;

  ExpenseProvider() {
    box = Hive.box<Expense>('expenses');
    loadExpenses();
    fetchRate();
  }

  //  LOAD
  void loadExpenses() {
    _expenses = box.values.toList();
    notifyListeners();
  }

  //  API RATE
  Future<void> fetchRate() async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://api.exchangerate.host/latest?base=USD&symbols=UZS",
        ),
      );

      final data = jsonDecode(res.body);
      _rate = (data["rates"]["UZS"] as num).toDouble();
      notifyListeners();
    } catch (_) {
      _rate = 12500;
    }
  }

  // SWITCH CURRENCY
  void toggleCurrency() {
    isUzs = !isUzs;
    notifyListeners();
  }

  // CONVERT
  double convert(double amount) {
    return isUzs ? amount * _rate : amount;
  }

  // FORMAT STRING
  String format(double amount) {
    final value = convert(amount);

    return isUzs
        ? "${value.toStringAsFixed(0)} so'm"
        : "\$${value.toStringAsFixed(2)}";
  }

  //  ADD
  void addExpense(Expense expense) {
    box.add(expense);
    loadExpenses();
  }

  // DELETE
  Expense deleteExpense(int index) {
    final deleted = _expenses[index];
    final key = box.keyAt(index);
    box.delete(key);
    loadExpenses();
    return deleted;
  }

  //  RESTORE
  void restoreExpense(Expense expense) {
    box.add(expense);
    loadExpenses();
  }

  // UPDATE
  void updateExpense(int index, Expense updated) {
    final key = box.keyAt(index);
    box.put(key, updated);
    loadExpenses();
  }

  //  FILTERED LIST
  List<Expense> get filteredExpenses {
    final now = DateTime.now();

    return _expenses.where((e) {
      if (_filter == FilterType.day) {
        return e.date.day == now.day &&
            e.date.month == now.month &&
            e.date.year == now.year;
      }

      if (_filter == FilterType.month) {
        return e.date.month == now.month &&
            e.date.year == now.year;
      }

      if (_filter == FilterType.year) {
        return e.date.year == now.year;
      }

      return true;
    }).toList();
  }

  // TOTAL
  double get total =>
      _expenses.fold(0, (sum, item) => sum + item.amount);

  //  AVERAGE PER TRANSACTION
  double get averagePerTransaction =>
      _expenses.isEmpty ? 0 : total / _expenses.length;

  //  AVERAGE PER DAY (NEW)
  double get averagePerDay {
    if (_expenses.isEmpty) return 0;

    final sorted = [..._expenses]
      ..sort((a, b) => a.date.compareTo(b.date));

    final first = sorted.first.date;
    final last = sorted.last.date;

    final days = last.difference(first).inDays + 1;

    return days <= 0 ? total : total / days;
  }
}
