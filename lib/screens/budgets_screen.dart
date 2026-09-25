import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/add_edit_budget_modal.dart';
import '../widgets/custom_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/toast_notification.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final budgets = financeProvider.budgets;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budgets & Limits',
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Monitor category spending',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddEditBudgetModal(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Budget'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (budgets.isEmpty)
              EmptyState(
                icon: Icons.pie_chart_outline_rounded,
                title: 'No active budgets',
                description: 'Set category budgets to avoid overspending and reach your financial goals.',
                actionLabel: 'Create Budget',
                onAction: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddEditBudgetModal(),
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  final category = financeProvider.getCategoryById(budget.categoryId);
                  final spent = financeProvider.getCategorySpentCurrentMonth(budget.categoryId);
                  final remaining = (budget.amountLimit - spent);
                  final ratio = (spent / budget.amountLimit).clamp(0.0, 1.5);

                  Color statusColor;
                  String statusLabel;
                  if (ratio >= 1.0) {
                    statusColor = AppColors.expense;
                    statusLabel = 'Over Budget!';
                  } else if (ratio >= 0.8) {
                    statusColor = AppColors.warning;
                    statusLabel = 'Near Limit';
                  } else {
                    statusColor = AppColors.income;
                    statusLabel = 'Healthy';
                  }

                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (category != null ? Color(category.colorValue) : AppColors.primary).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category != null ? IconData(category.iconCode, fontFamily: 'MaterialIcons') : Icons.category,
                                color: category != null ? Color(category.colorValue) : AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category?.name ?? 'Category',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${budget.period.name.toUpperCase()} BUDGET',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => AddEditBudgetModal(existingBudget: budget),
                                  );
                                } else if (val == 'delete') {
                                  financeProvider.deleteBudget(budget.id);
                                  ToastNotification.show(context, message: 'Budget deleted', type: ToastType.error);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Spent: ${CurrencyUtils.format(spent, currencyCode: currency)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Limit: ${CurrencyUtils.format(budget.amountLimit, currencyCode: currency)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: statusColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          remaining >= 0
                              ? '${CurrencyUtils.format(remaining, currencyCode: currency)} remaining this month'
                              : '${CurrencyUtils.format(remaining.abs(), currencyCode: currency)} over budget limit',
                          style: TextStyle(
                            fontSize: 13,
                            color: remaining < 0 ? AppColors.expense : AppColors.textSecondaryLight,
                            fontWeight: remaining < 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
