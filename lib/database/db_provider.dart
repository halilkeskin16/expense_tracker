import 'package:expense_tracker/models/income.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DbProvider {
  static const _databaseName = "expense_tracker.db";
  static const _databaseVersion = 2;

  // Expenses

  static const expenseTable = 'expenses';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnAmount = 'amount';
  static const columnDate = 'date';
  static const columnCategory = 'category';

  // Incomes
  static const incomeTable = 'incomes';
  static const incomeColumnId = 'id';
  static const incomeColumnTitle = 'title';
  static const incomeColumnAmount = 'amount';
  static const incomeColumnDate = 'date';
  static const incomeColumnCategory = 'category';

  DbProvider._privateConstructor();
  static final DbProvider instance = DbProvider._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('DROP TABLE IF EXISTS $expenseTable'); // İf exists , drop expense table , create new one later
    await db.execute('DROP TABLE IF EXISTS $incomeTable'); // İf exists , drop income table , create new one later

    // Create Expense Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $expenseTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnCategory TEXT NOT NULL
      )
    ''');

    // Create Income Table
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS $incomeTable (
        $incomeColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $incomeColumnTitle TEXT NOT NULL,
        $incomeColumnAmount REAL NOT NULL,
        $incomeColumnDate TEXT NOT NULL,
        $incomeColumnCategory TEXT NOT NULL
      )
    ''');
  }

  // Expense Operations
  Future<int> expenseInsert(Expense expense) async {
    Database db = await instance.database;
    return await db.insert(expenseTable, expense.toMap());
  }

  Future<List<Expense>> queryAlExpensesRows() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query(expenseTable, orderBy: '$columnDate DESC');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<Expense?> queryRow(int id) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query(expenseTable, where: '$columnId = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  Future<int> expenseUpdate(Expense expense) async {
    Database db = await instance.database;
    return await db.update(
      expenseTable,
      expense.toMap(),
      where: '$columnId = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> expenseDelete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      expenseTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> expenseDeleteAll() async {
    Database db = await instance.database;
    return await db.delete(expenseTable);
  }

  Future<double> expenseGetTotalExpenses() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db
        .rawQuery('SLEECT SUM($columnAmount) as total FROM $expenseTable');
    return result.first['total'] ?? 0.0;
  }

  Future<Map<ExpenseCategory, double>> expenseGetExpensesByCategory() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT $columnCategory, SUM($columnAmount) as total
      FROM $expenseTable
      GROUP BY $columnCategory
    ''');

    return Map.fromEntries(
      results.map((row) => MapEntry(
            ExpenseCategory.values
                .firstWhere((e) => e.name == row[columnCategory]),
            (row['total'] as num).toDouble(),
          )),
    );
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      expenseTable,
      where: '$columnDate BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: '$columnDate DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Income Operations
  Future<int> incomeInsert(Income income) async {
    Database db = await instance.database;
    return await db.insert(incomeTable, income.toMap());
  }
  Future<List<Income>> queryAllIncomes() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(incomeTable , orderBy: '$incomeColumnDate DESC');
    return List.generate(maps.length, (i) => Income.fromMap(maps[i]));
  }

  Future<Income?> queryIncomeRow(int id) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(incomeTable, where: '$incomeColumnId = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Income.fromMap(maps.first);
  }
  
  Future<int> incomeUpdate(Income income) async {
    Database db = await instance.database;
    return await db.update(incomeTable, income.toMap(), where: '$incomeColumnId = ?', whereArgs: [income.id]);
  }

  Future<int> incomeDelete(int id) async {
    Database db = await instance.database;
    return await db.delete(incomeTable, where: '$incomeColumnId = ?', whereArgs: [id]);
  }

  Future<int> incomeDeleteAll() async {
    Database db = await instance.database;
    return await db.delete(incomeTable);
  }

  Future<double> incomeGetTotalIncomes() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT SUM($incomeColumnAmount) as total FROM $incomeTable');
    return result.first['total'] ?? 0.0;
  }

  Future<Map<IncomeCategory, double>> incomeGetIncomesByCategory() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT $incomeColumnCategory, SUM($incomeColumnAmount) as total
      FROM $incomeTable
      GROUP BY $incomeColumnCategory
    ''');
    
    return Map.fromEntries(
      results.map((row) => MapEntry(
            IncomeCategory.values
                .firstWhere((e) => e.name == row[incomeColumnCategory]),
            (row['total'] as num).toDouble(),
          )),
    );
  } 
}