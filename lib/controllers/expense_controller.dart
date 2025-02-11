import 'dart:convert';
import 'package:daily_spending/models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseController {
  static const String _expensesKey = 'expenses';
  static const String _categoriesKey = 'categories';
  final SharedPreferences _prefs;

  ExpenseController(this._prefs);

  Future<List<String>> getCategories() async {
    return _prefs.getStringList(_categoriesKey) ?? ['Alimentação', 'Transporte', 'Lazer'];
  }

  Future<void> addCategory(String category) async {
    final categories = await getCategories();
    if (!categories.contains(category)) {
      categories.add(category);
      await _prefs.setStringList(_categoriesKey, categories);
    }
  }

  Future<List<Expense>> getFilteredExpenses(String period) async {
    List<Expense> expenses = await getExpenses();
    final now = DateTime.now();

    return expenses.where((expense) {
      final difference = now.difference(expense.date);
      switch (period) {
        case 'daily':
          return difference.inDays == 0;
        case 'weekly':
          return difference.inDays <= 7;
        case 'monthly':
          return expense.date.year == now.year && 
                 expense.date.month == now.month;
        case 'semiannual':
          return difference.inDays <= 180;
        case 'yearly':
          return expense.date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  Future<List<Expense>> getExpenses() async {
    final String? data = _prefs.getString(_expensesKey);
    if (data == null) return [];

    List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Expense.fromJson(json)).toList();
  }

  Future<void> addExpense(Expense expense) async {
    List<Expense> expenses = await getExpenses();
    expenses.add(expense);
    
    final String data = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await _prefs.setString(_expensesKey, data);
  }

  Future<Map<String, double>> getFilteredTotals(String period) async {
    List<Expense> expenses = await getExpenses();
    DateTime now = DateTime.now();
    
    expenses = expenses.where((expense) {
      if (period == 'weekly') {
        return now.difference(expense.date).inDays <= 7;
      } else if (period == 'monthly') {
        return expense.date.year == now.year && 
               expense.date.month == now.month;
      } else {
        return expense.date.year == now.year;
      }
    }).toList();

    Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.value;
    }
    
    return totals;
  }

  Future<void> removeExpense(String id) async {
    List<Expense> expenses = await getExpenses();
    expenses.removeWhere((expense) => expense.id == id);
    
    final String data = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await _prefs.setString(_expensesKey, data);
  }

  Future<bool> removeCategory(String category) async {
    List<Expense> expenses = await getExpenses();
    bool hasExpenses = expenses.any((expense) => expense.category == category);
    
    if (hasExpenses) {
      return false;
    }

    List<String> categories = await getCategories();
    categories.remove(category);
    await _prefs.setStringList(_categoriesKey, categories);
    return true;
  }
}
