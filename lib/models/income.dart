enum IncomeCategory {
  salary,
  investment,
  sideJob,
  other,
}

class Income {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final IncomeCategory category;

  Income({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: IncomeCategory.values.firstWhere((e) => e.name == map['category'], orElse: () => IncomeCategory.other),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
    };
  }

  Income copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    IncomeCategory? category,
  }) {
    return Income(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Income(id: $id, title: $title, amount: $amount, date: $date, category: $category)';
  }

}