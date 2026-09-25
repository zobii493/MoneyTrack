import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transaction_detail_modal.dart';
import '../widgets/add_edit_transaction_modal.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _typeFilter = 'All'; // 'All', 'Income', 'Expense', 'Transfer'
  String? _selectedCategory;
  String? _selectedAccount;

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    // Apply filtering
    List<TransactionModel> filtered = financeProvider.transactions.where((t) {
      // Type filter
      if (_typeFilter == 'Income' && t.type != TransactionType.income) return false;
      if (_typeFilter == 'Expense' && t.type != TransactionType.expense) return false;
      if (_typeFilter == 'Transfer' && t.type != TransactionType.transfer) return false;

      // Category filter
      if (_selectedCategory != null && t.categoryId != _selectedCategory) return false;

      // Account filter
      if (_selectedAccount != null && t.accountId != _selectedAccount && t.toAccountId != _selectedAccount) return false;

      // Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = t.title.toLowerCase().contains(query);
        final descMatch = t.description.toLowerCase().contains(query);
        final noteMatch = t.notes?.toLowerCase().contains(query) ?? false;
        final amountMatch = t.amount.toString().contains(query);
        if (!titleMatch && !descMatch && !noteMatch && !amountMatch) return false;
      }

      return true;
    }).toList();

    // Sort by date descending
    filtered.sort((a, b) => b.date.compareTo(a.date));

    // Group by Date Header
    final Map<String, List<TransactionModel>> groupedTxns = {};
    for (var txn in filtered) {
      final headerKey = DateUtilsHelper.formatDateGroupHeader(txn.date);
      groupedTxns.putIfAbsent(headerKey, () => []).add(txn);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search & Add Button Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddEditTransactionModal(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category & Account Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip('All'),
                  _buildTypeChip('Income'),
                  _buildTypeChip('Expense'),
                  _buildTypeChip('Transfer'),
                  const SizedBox(width: 12),
                  // Category Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedCategory,
                        hint: const Text('Category'),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Categories')),
                          ...financeProvider.categories.map((c) {
                            return DropdownMenuItem(value: c.id, child: Text(c.name));
                          }),
                        ],
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Account Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedAccount,
                        hint: const Text('Account'),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Accounts')),
                          ...financeProvider.accounts.map((a) {
                            return DropdownMenuItem(value: a.id, child: Text(a.name));
                          }),
                        ],
                        onChanged: (val) => setState(() => _selectedAccount = val),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Transaction List
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions found',
                      description: 'Try adjusting your search query or filters to find your transactions.',
                      actionLabel: 'Add Transaction',
                      onAction: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AddEditTransactionModal(),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: groupedTxns.keys.length,
                      itemBuilder: (context, index) {
                        final dateHeader = groupedTxns.keys.elementAt(index);
                        final txns = groupedTxns[dateHeader]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: Text(
                                dateHeader,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ),
                            Card(
                              child: Column(
                                children: List.generate(txns.length, (i) {
                                  final txn = txns[i];
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
                                      if (i < txns.length - 1)
                                        const Divider(height: 1, indent: 68),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    final isSelected = _typeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          setState(() => _typeFilter = label);
        },
      ),
    );
  }
}
