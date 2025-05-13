import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DbProvider {
  static const _databaseName = "expense_tracker.db";
  static const _databaseVersion = 1;

  static const expenseTable = 'expenses';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnAmount = 'amount';
  static const columnDate = 'date';
  static const columnCategory = 'category';

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
    await db.execute('DROP TABLE IF EXISTS $expenseTable');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $expenseTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnCategory TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Expense expense) async {
    Database db = await instance.database;
    return await db.insert(expenseTable, expense.toMap());
  }

  Future<List<Expense>> queryAllRows() async {
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

  Future<int> update(Expense expense) async {
    Database db = await instance.database;
    return await db.update(
      expenseTable,
      expense.toMap(),
      where: '$columnId = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      expenseTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(expenseTable);
  }

  Future<double> getTotalExpenses() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db
        .rawQuery('SELECT SUM($columnAmount) as total FROM $expenseTable');
    return result.first['total'] ?? 0.0;
  }

  Future<Map<ExpenseCategory, double>> getExpensesByCategory() async {
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
}