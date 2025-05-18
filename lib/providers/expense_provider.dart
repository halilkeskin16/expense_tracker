import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/database/db_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  double _totalExpenses = 0;
  Map<ExpenseCategory, double> _expensesByCategory = {};

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  double get totalExpenses => _totalExpenses;
  Map<ExpenseCategory, double> get expensesByCategory => _expensesByCategory;

  //Load Expenses
  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await DbProvider.instance.queryAllRows();
      _totalExpenses = await DbProvider.instance.expenseGetTotalExpenses();
      _expensesByCategory = await DbProvider.instance.expenseGetExpensesByCategory();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Add Expense
  Future<void> addExpense(Expense expense) async {
    try {
      await DbProvider.instance.expenseInsert(expense);
      await loadExpenses();
    } catch (e) {
      debugPrint("Error adding expense: $e");
    } 
  }

  //Delete one Expense 
  Future<void> deleteExpense(int id) async {
    try {
      await DbProvider.instance.expenseDelete(id);
      await loadExpenses();
    } catch (e) {
      debugPrint("Error deleting expense: $e");
    }
  }
  //Update Expense
  Future<void> updateExpense(Expense expense) async {
    try {
      await DbProvider.instance.expenseUpdate(expense);
      await loadExpenses();
    } catch (e) {
      debugPrint("Error updating expense: $e");
    }
  }

  Map<DateTime, double> getWeeklyExpenses() {
    final now = DateTime.now();
    final Map<DateTime, double> weeklyExpenses = {};

    for (int i = 0; i <= 6; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      weeklyExpenses[date] = 0;
    }

    for(var expense in _expenses) {
      final expensesDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if(now.difference(expensesDate).inDays <= 6) {
        weeklyExpenses.update(expensesDate, (value) => value + expense.amount, ifAbsent: () => expense.amount);
      }
    }
    return weeklyExpenses;
  }

  // Delete all expenses
  Future<void> deleteAllExpenses() async {
    try {
      await DbProvider.instance.expenseDeleteAll();
      await loadExpenses();
    } catch (e) {
      debugPrint("Error deleting all expenses: $e");
    }
  }
}
