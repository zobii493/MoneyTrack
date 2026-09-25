import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'custom_card.dart';

class ExpenseBreakdownChart extends StatefulWidget {
  const ExpenseBreakdownChart({super.key});

  @override
  State<ExpenseBreakdownChart> createState() => _ExpenseBreakdownChartState();
}

class _ExpenseBreakdownChartState extends State<ExpenseBreakdownChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final expenseCategories = financeProvider.categories
        .where((c) => c.type.name == 'expense')
        .toList();

    double totalExpenseSum = 0;
    final Map<String, double> categoryAmounts = {};

    for (var cat in expenseCategories) {
      final spent = financeProvider.getCategorySpentCurrentMonth(cat.id);
      if (spent > 0) {
        categoryAmounts[cat.id] = spent;
        totalExpenseSum += spent;
      }
    }

    if (totalExpenseSum == 0) {
      totalExpenseSum = 1500;
      categoryAmounts['cat_food'] = 420;
      categoryAmounts['cat_transport'] = 260;
      categoryAmounts['cat_shopping'] = 230;
      categoryAmounts['cat_bills'] = 310;
      categoryAmounts['cat_entertainment'] = 180;
      categoryAmounts['cat_subscriptions'] = 100;
    }

    final activeItems = categoryAmounts.entries.toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'This Month',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 130,
                width: 130,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 36,
                    sections: List.generate(activeItems.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final radius = isTouched ? 30.0 : 25.0;
                      final entry = activeItems[i];
                      final cat = financeProvider.getCategoryById(entry.key);
                      final color = cat != null ? Color(cat.colorValue) : AppColors.primary;
                      final percentage = (entry.value / totalExpenseSum * 100).toStringAsFixed(0);

                      return PieChartSectionData(
                        color: color,
                        value: entry.value,
                        title: '$percentage%',
                        radius: radius,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: List.generate(
                    activeItems.length > 4 ? 4 : activeItems.length,
                    (i) {
                      final entry = activeItems[i];
                      final cat = financeProvider.getCategoryById(entry.key);
                      final catName = cat?.name ?? 'Category';
                      final color = cat != null ? Color(cat.colorValue) : AppColors.primary;
                      final pct = (entry.value / totalExpenseSum * 100).toStringAsFixed(0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                catName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${CurrencyUtils.formatCompact(entry.value, currencyCode: currency)} ($pct%)',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
