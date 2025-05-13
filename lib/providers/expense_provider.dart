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
  Future<void> _loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await DbProvider.instance.queryAllRows();
      _totalExpenses = await DbProvider.instance.getTotalExpenses();
      _expensesByCategory = await DbProvider.instance.getExpensesByCategory();
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
      await DbProvider.instance.insert(expense);
      await _loadExpenses();
    } catch (e) {
      debugPrint("Error adding expense: $e");
    } 
  }

  //Delete Expense 
  Future<void> deleteExpense(int id) async {
    try {
      await DbProvider.instance.delete(id);
      await _loadExpenses();
    } catch (e) {
      debugPrint("Error deleting expense: $e");
    }
  }
  //Update Expense
  
  
}
