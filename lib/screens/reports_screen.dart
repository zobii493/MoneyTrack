import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/custom_card.dart';
import '../widgets/toast_notification.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _reportType = 'Monthly Expense Report';
  final List<String> _reportTypes = [
    'Monthly Expense Report',
    'Income Report',
    'Spending Category Report',
    'Budget Report',
    'Annual Financial Summary',
  ];

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final totalIncome = financeProvider.totalIncomeMonth;
    final totalExpense = financeProvider.totalExpenseMonth;
    final netSavings = totalIncome - totalExpense;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financial Reports', style: Theme.of(context).textTheme.headlineMedium),
                      Text('Generate & export summaries', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ToastNotification.show(context, message: 'Exporting CSV file...');
                              },
                              icon: const Icon(Icons.table_chart_outlined, size: 16),
                              label: const Text('Export CSV'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ToastNotification.show(context, message: 'Generating PDF report...');
                              },
                              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                              label: const Text('Export PDF'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Financial Reports', style: Theme.of(context).textTheme.headlineMedium),
                            Text('Generate and export comprehensive financial summaries', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              ToastNotification.show(context, message: 'Exporting CSV file...');
                            },
                            icon: const Icon(Icons.table_chart_outlined, size: 18),
                            label: const Text('Export CSV'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              ToastNotification.show(context, message: 'Generating PDF report...');
                            },
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                            label: const Text('Export PDF'),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            // Report Selector Dropdown
            DropdownButtonFormField<String>(
              value: _reportType,
              decoration: const InputDecoration(
                labelText: 'Select Report Type',
                prefixIcon: Icon(Icons.article_outlined),
              ),
              items: _reportTypes.map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _reportType = val);
              },
            ),
            const SizedBox(height: 24),

            // Printable Report Preview Container
            CustomCard(
              padding: const EdgeInsets.all(24),
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
                              'MoneyTrack Statement',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _reportType,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Executive Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _reportRow('Total Income Recorded', CurrencyUtils.format(totalIncome, currencyCode: currency), AppColors.income),
                  _reportRow('Total Expenses Recorded', CurrencyUtils.format(totalExpense, currencyCode: currency), AppColors.expense),
                  _reportRow('Net Cash Surplus / Savings', CurrencyUtils.format(netSavings, currencyCode: currency), AppColors.primary),
                  _reportRow('Total Accounts Balance', CurrencyUtils.format(financeProvider.totalBalance, currencyCode: currency), null),
                  const Divider(height: 32),
                  Text('Category Breakdown Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...financeProvider.categories.take(6).map((cat) {
                    final spent = financeProvider.getCategorySpentCurrentMonth(cat.id);
                    return _reportRow(cat.name, CurrencyUtils.format(spent, currencyCode: currency), null);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
