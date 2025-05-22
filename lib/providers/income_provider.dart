import 'package:expense_tracker/database/db_provider.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:flutter/material.dart';

class IncomeProvider  extends ChangeNotifier{
  List<Income> _incomes = [];
  bool _isLoading = false;
  double _totalIncome = 0;
  Map<IncomeCategory, double> _incomesByCategory = {};

  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;
  double get totalIncome => _totalIncome;
  Map<IncomeCategory, double> get incomesByCategory => _incomesByCategory;

  //Load Income

  Future<void> loadIncomes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _incomes = await DbProvider.instance.queryAllIncomes();
      _totalIncome = await DbProvider.instance.incomeGetTotalIncomes();
      _incomesByCategory = await DbProvider.instance.incomeGetIncomesByCategory();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}