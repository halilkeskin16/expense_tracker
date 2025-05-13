import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<ExpenseCategory, double> expensesByCategory;
  final double totalExpenses;

  const CategoryPieChart({
    super.key,
    required this.expensesByCategory,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    if (expensesByCategory.isEmpty || totalExpenses == 0) {
      return const Center(
        child: Text('Henüz harcama verisi yok'),
      );
    }
    return SizedBox(
      height: 140,
      child: PieChart(
        PieChartData(
          sections: _createPieSections(),
          sectionsSpace: 1.5,
          centerSpaceRadius: 32,
          startDegreeOffset: 180,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Handle touch events if needed
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieSections() {
    final List<PieChartSectionData> sections = [];
    // Define colors for each category
    final Map<ExpenseCategory, Color> categoryColors = {
      ExpenseCategory.food: const Color(0xFF9B8BFF), // Canlı pastel mor
      ExpenseCategory.transportation: const Color(0xFF6750A4), // Canlı pastel turkuaz
      ExpenseCategory.entertainment: const Color(0xFFFF8B8B), // Canlı pastel kırmızı
      ExpenseCategory.shopping: const Color(0xFF8BFF9B), // Canlı pastel yeşil
      ExpenseCategory.utilities: const Color(0xFFFFD08B), // Canlı pastel turuncu
      ExpenseCategory.health: const Color(0xFFFF8BE3), // Canlı pastel pembe
      ExpenseCategory.other: const Color(0xFFB8B8B8), // Modern gri
    };

    // Create pie sections for each category
    expensesByCategory.forEach((category, amount) {
      final double percentage = (amount / totalExpenses) * 100;
      final Color color = categoryColors[category] ?? Colors.grey;
      sections.add(
        PieChartSectionData(
          value: amount,
          title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
          color: color,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    });

    return sections;
  }
}

class CategoryLegend extends StatelessWidget {
  final Map<ExpenseCategory, double> expensesByCategory;
  final double totalExpenses;

  const CategoryLegend({
    super.key,
    required this.expensesByCategory,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    if (expensesByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    // Define colors and icons for each category
    final Map<ExpenseCategory, Color> categoryColors = {
      ExpenseCategory.food: const Color(0xFF6750A4),
      ExpenseCategory.transportation: const Color(0xFF6750A4),
      ExpenseCategory.entertainment: const Color(0xFFEF5350),
      ExpenseCategory.shopping: const Color(0xFF4CAF50),
      ExpenseCategory.utilities: const Color(0xFFFFA726),
      ExpenseCategory.health: const Color(0xFFEC407A),
      ExpenseCategory.other: const Color(0xFF78909C),
    };

    final Map<ExpenseCategory, IconData> categoryIcons = {
      ExpenseCategory.food: Icons.restaurant,
      ExpenseCategory.transportation: Icons.directions_car,
      ExpenseCategory.entertainment: Icons.movie,
      ExpenseCategory.shopping: Icons.shopping_bag,
      ExpenseCategory.utilities: Icons.lightbulb,
      ExpenseCategory.health: Icons.medical_services,
      ExpenseCategory.other: Icons.more_horiz,
    };

    final Map<ExpenseCategory, String> categoryNames = {
      ExpenseCategory.food: 'Yemek',
      ExpenseCategory.transportation: 'Ulaşım',
      ExpenseCategory.entertainment: 'Eğlence',
      ExpenseCategory.shopping: 'Alışveriş',
      ExpenseCategory.utilities: 'Faturalar',
      ExpenseCategory.health: 'Sağlık',
      ExpenseCategory.other: 'Diğer',
    };

    // Create legend items for each category
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: expensesByCategory.keys.map((category) {
        final amount = expensesByCategory[category]!;
        final percentage = (amount / totalExpenses) * 100;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: categoryColors[category]!.withAlpha(51),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoryIcons[category],
                color: categoryColors[category],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                categoryNames[category]!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}