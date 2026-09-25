import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_breakdown_chart.dart';
import '../widgets/financial_summary_cards.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transaction_detail_modal.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onViewAllTransactions;

  const DashboardScreen({
    super.key,
    required this.onViewAllTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final widgets = user?.dashboardWidgets ?? {};

    final recentTxns = financeProvider.transactions.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card Widget
          if (widgets['balance'] ?? true) ...[
            const BalanceCard(),
            const SizedBox(height: 20),
          ],

          // Summary Cards Widget
          if (widgets['summary'] ?? true) ...[
            const FinancialSummaryCards(),
            const SizedBox(height: 20),
          ],

          // Charts Section (Responsive Grid or Column)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widgets['spending_chart'] ?? true)
                      const Expanded(flex: 3, child: SpendingChart()),
                    if ((widgets['spending_chart'] ?? true) && (widgets['expense_breakdown'] ?? true))
                      const SizedBox(width: 20),
                    if (widgets['expense_breakdown'] ?? true)
                      const Expanded(flex: 2, child: ExpenseBreakdownChart()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    if (widgets['spending_chart'] ?? true) ...[
                      const SpendingChart(),
                      const SizedBox(height: 20),
                    ],
                    if (widgets['expense_breakdown'] ?? true) ...[
                      const ExpenseBreakdownChart(),
                      const SizedBox(height: 20),
                    ],
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // Recent Transactions Section
          if (widgets['recent_transactions'] ?? true) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onViewAllTransactions,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentTxns.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No transactions recorded yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: List.generate(recentTxns.length, (index) {
                      final txn = recentTxns[index];
                      return Column(
                        children: [
                          TransactionTile(
                            transaction: txn,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => TransactionDetailModal(transaction: txn),
                              );
                            },
                          ),
                          if (index < recentTxns.length - 1)
                            const Divider(height: 1, indent: 68),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
