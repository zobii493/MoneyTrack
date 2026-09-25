import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/custom_card.dart';
import '../widgets/expense_breakdown_chart.dart';
import '../widgets/spending_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final currentExpense = financeProvider.totalExpenseMonth;
    final currentIncome = financeProvider.totalIncomeMonth;
    final savingsRate = currentIncome > 0
        ? ((currentIncome - currentExpense) / currentIncome * 100).clamp(0.0, 100.0).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Analytics', style: Theme.of(context).textTheme.headlineMedium),
            Text('Deep insights into your cash flow and spending trends', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // Key Metrics Summary Bar
            LayoutBuilder(builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return GridView.count(
                crossAxisCount: isMobile ? 2 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.6 : 2.0,
                children: [
                  _MetricCard(
                    title: 'Monthly Cash Flow',
                    value: CurrencyUtils.format(currentIncome - currentExpense, currencyCode: currency),
                    icon: Icons.swap_vert,
                    color: AppColors.income,
                  ),
                  _MetricCard(
                    title: 'Savings Rate',
                    value: '$savingsRate%',
                    icon: Icons.percent,
                    color: AppColors.savings,
                  ),
                  _MetricCard(
                    title: 'Avg. Daily Expense',
                    value: CurrencyUtils.format(currentExpense / 30, currencyCode: currency),
                    icon: Icons.today,
                    color: AppColors.warning,
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),

            // Spending Trends & Breakdown Charts
            const SpendingChart(),
            const SizedBox(height: 20),
            const ExpenseBreakdownChart(),
            const SizedBox(height: 20),

            // Spending Insights Section
            Text('Automated Financial Insights', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.lightbulb_outline,
              color: AppColors.primary,
              title: 'Great dining discipline!',
              message: 'You spent 18% less on dining and restaurants this month compared to last month.',
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.show_chart,
              color: AppColors.savings,
              title: 'Savings Rate Boost',
              message: 'Your overall savings rate increased by 6% due to steady freelance income.',
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.directions_car_outlined,
              color: AppColors.warning,
              title: 'Transportation Trend',
              message: 'Transportation is currently your second-highest spending category this month.',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
