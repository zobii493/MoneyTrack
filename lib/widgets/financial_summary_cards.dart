import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'custom_card.dart';

class FinancialSummaryCards extends StatelessWidget {
  const FinancialSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final income = financeProvider.totalIncomeMonth;
    final expense = financeProvider.totalExpenseMonth;
    final savings = financeProvider.totalSavingsMonth;
    final available = financeProvider.availableBalance;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = isMobile ? 2 : 4;
        final childAspectRatio = isMobile ? 1.4 : 1.5;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: [
            _SummaryCardItem(
              title: 'Income',
              amount: CurrencyUtils.format(income, currencyCode: currency),
              percentage: '+12.4%',
              isPositive: true,
              icon: Icons.south_west_rounded,
              iconColor: AppColors.income,
            ),
            _SummaryCardItem(
              title: 'Expenses',
              amount: CurrencyUtils.format(expense, currencyCode: currency),
              percentage: '-4.8%',
              isPositive: false,
              icon: Icons.north_east_rounded,
              iconColor: AppColors.expense,
            ),
            _SummaryCardItem(
              title: 'Savings',
              amount: CurrencyUtils.format(savings, currencyCode: currency),
              percentage: '+18.2%',
              isPositive: true,
              icon: Icons.savings_outlined,
              iconColor: AppColors.savings,
            ),
            _SummaryCardItem(
              title: 'Available',
              amount: CurrencyUtils.format(available, currencyCode: currency),
              percentage: 'Safe',
              isPositive: true,
              icon: Icons.account_balance_outlined,
              iconColor: AppColors.warning,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCardItem extends StatelessWidget {
  final String title;
  final String amount;
  final String percentage;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;

  const _SummaryCardItem({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.income : AppColors.expense).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    color: isPositive ? AppColors.income : AppColors.expense,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
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
