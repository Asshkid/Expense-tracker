import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/stats_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => HomeScreen(),
    '/add': (context) => AddExpenseScreen(),
    '/stats': (context) => StatsScreen(),
  };
}