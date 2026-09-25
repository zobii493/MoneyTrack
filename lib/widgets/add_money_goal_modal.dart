import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'toast_notification.dart';

class AddMoneyGoalModal extends StatefulWidget {
  final GoalModel goal;

  const AddMoneyGoalModal({super.key, required this.goal});

  @override
  State<AddMoneyGoalModal> createState() => _AddMoneyGoalModalState();
}

class _AddMoneyGoalModalState extends State<AddMoneyGoalModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedAccountId == null && financeProvider.accounts.isNotEmpty) {
      _selectedAccountId = financeProvider.accounts.first.id;
    }

    final remaining = (widget.goal.targetAmount - widget.goal.currentAmount).clamp(0.0, double.infinity);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Money to Goal', style: Theme.of(context).textTheme.headlineMedium),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Goal: ${widget.goal.title}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                ),
                Text(
                  'Remaining: ${CurrencyUtils.format(remaining, currencyCode: currency)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Contribution Amount (${authProvider.user?.currency ?? 'USD'})',
                    prefixIcon: const Icon(Icons.add_card),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter amount';
                    if (double.tryParse(val) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Deduct From Account',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: financeProvider.accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text('${acc.name} (${CurrencyUtils.format(acc.balance, currencyCode: currency)})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAccountId = val),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Add Money'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final amount = double.parse(_amountController.text.trim());

    financeProvider.addMoneyToGoal(
      widget.goal.id,
      amount,
      accountId: _selectedAccountId,
    );

    Navigator.pop(context);
    ToastNotification.show(context, message: 'Added ${CurrencyUtils.format(amount)} to goal!');
  }
}
