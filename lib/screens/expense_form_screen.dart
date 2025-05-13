import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.expense != null) {
      _isEditing = true;
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Harcama Düzenle' : 'Harcama Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir tutar girin';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Lütfen geçerli bir sayı girin';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Tutar sıfırdan büyük olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarih',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat.yMMMd().format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category dropdown
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: ExpenseCategory.values.map((category) {
                  IconData icon;
                  switch (category) {
                    case ExpenseCategory.food:
                      icon = Icons.restaurant;
                      break;
                    case ExpenseCategory.transportation:
                      icon = Icons.directions_car;
                      break;
                    case ExpenseCategory.entertainment:
                      icon = Icons.movie;
                      break;
                    case ExpenseCategory.shopping:
                      icon = Icons.shopping_bag;
                      break;
                    case ExpenseCategory.utilities:
                      icon = Icons.lightbulb;
                      break;
                    case ExpenseCategory.health:
                      icon = Icons.medical_services;
                      break;
                    case ExpenseCategory.other:
                      icon = Icons.more_horiz;
                      break;
                  }
                  
                  return DropdownMenuItem<ExpenseCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: 8),
                        Text(_getCategoryNameInTurkish(category)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: Text(
                    _isEditing ? 'Harcamayı Güncelle' : 'Harcama Ekle',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _getCategoryNameInTurkish(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return 'YEMEK';
      case ExpenseCategory.transportation:
        return 'ULAŞIM';
      case ExpenseCategory.entertainment:
        return 'EĞLENCE';
      case ExpenseCategory.shopping:
        return 'ALIŞVERİŞ';
      case ExpenseCategory.utilities:
        return 'FATURALAR';
      case ExpenseCategory.health:
        return 'SAĞLIK';
      case ExpenseCategory.other:
        return 'DİĞER';
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      
      final expense = Expense(
        id: _isEditing ? widget.expense!.id : null,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
      );
      if (_isEditing) {
        expenseProvider.updateExpense(expense);
      } else {
        expenseProvider.addExpense(expense);
      }

      Navigator.pop(context);
    }
  }
}