import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/add_edit_account_modal.dart';
import '../widgets/custom_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/toast_notification.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final accounts = financeProvider.accounts;

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
                        'Financial Accounts',
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Manage banks, savings & cash balances',
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
                      builder: (_) => const AddEditAccountModal(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Account'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (accounts.isEmpty)
              EmptyState(
                icon: Icons.account_balance_outlined,
                title: 'No accounts configured',
                description: 'Add cash wallets, bank accounts, or savings accounts to organize balances.',
                actionLabel: 'Add Account',
                onAction: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddEditAccountModal(),
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final acc = accounts[index];
                  final isNegative = acc.balance < 0;
                  final accColor = Color(acc.colorValue);

                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accColor.withOpacity(0.2)),
                          ),
                          child: Icon(
                            IconData(acc.iconCode, fontFamily: 'MaterialIcons'),
                            color: accColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acc.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                acc.accountNumberMasked ?? acc.type.name.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyUtils.format(acc.balance, currencyCode: currency, showSign: isNegative),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isNegative ? AppColors.expense : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Updated ${DateUtilsHelper.formatShortDate(acc.updatedAt)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          iconSize: 20,
                          onSelected: (val) {
                            if (val == 'edit') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => AddEditAccountModal(existingAccount: acc),
                              );
                            } else if (val == 'delete') {
                              financeProvider.deleteAccount(acc.id);
                              ToastNotification.show(context, message: 'Account deleted', type: ToastType.error);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
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
