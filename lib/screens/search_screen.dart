import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transaction_detail_modal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final queryLower = _query.trim().toLowerCase();

    final matchedTxns = queryLower.isEmpty
        ? []
        : financeProvider.transactions.where((t) {
            return t.title.toLowerCase().contains(queryLower) ||
                t.description.toLowerCase().contains(queryLower) ||
                (t.notes?.toLowerCase().contains(queryLower) ?? false) ||
                t.amount.toString().contains(queryLower);
          }).toList();

    final matchedCategories = queryLower.isEmpty
        ? []
        : financeProvider.categories.where((c) => c.name.toLowerCase().contains(queryLower)).toList();

    final matchedAccounts = queryLower.isEmpty
        ? []
        : financeProvider.accounts.where((a) => a.name.toLowerCase().contains(queryLower)).toList();

    final matchedGoals = queryLower.isEmpty
        ? []
        : financeProvider.goals.where((g) => g.title.toLowerCase().contains(queryLower)).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (val) => setState(() => _query = val),
          decoration: const InputDecoration(
            hintText: 'Search transactions, categories, goals...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
      body: queryLower.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Type to search across MoneyTrack', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transactions match
                  if (matchedTxns.isNotEmpty) ...[
                    Text('Transactions (${matchedTxns.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: List.generate(matchedTxns.length, (i) {
                          final txn = matchedTxns[i];
                          return TransactionTile(
                            transaction: txn,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => TransactionDetailModal(transaction: txn),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Goals match
                  if (matchedGoals.isNotEmpty) ...[
                    Text('Goals (${matchedGoals.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...matchedGoals.map((g) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.flag, color: AppColors.primary),
                          title: Text(g.title),
                          subtitle: Text('Target: ${CurrencyUtils.format(g.targetAmount, currencyCode: currency)}'),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                  ],

                  // Accounts match
                  if (matchedAccounts.isNotEmpty) ...[
                    Text('Accounts (${matchedAccounts.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...matchedAccounts.map((a) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.account_balance, color: AppColors.primary),
                          title: Text(a.name),
                          subtitle: Text('Balance: ${CurrencyUtils.format(a.balance, currencyCode: currency)}'),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                  ],

                  // Categories match
                  if (matchedCategories.isNotEmpty) ...[
                    Text('Categories (${matchedCategories.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...matchedCategories.map((c) {
                      return Card(
                        child: ListTile(
                          leading: Icon(IconData(c.iconCode, fontFamily: 'MaterialIcons'), color: Color(c.colorValue)),
                          title: Text(c.name),
                          subtitle: Text(c.type.name.toUpperCase()),
                        ),
                      );
                    }).toList(),
                  ],

                  if (matchedTxns.isEmpty && matchedGoals.isEmpty && matchedAccounts.isEmpty && matchedCategories.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No matching results found.'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
