import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import 'toast_notification.dart';

class AddEditAccountModal extends StatefulWidget {
  final AccountModel? existingAccount;

  const AddEditAccountModal({super.key, this.existingAccount});

  @override
  State<AddEditAccountModal> createState() => _AddEditAccountModalState();
}

class _AddEditAccountModalState extends State<AddEditAccountModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _numberMaskedController;
  AccountType _selectedType = AccountType.bank;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAccount;
    _nameController = TextEditingController(text: a?.name ?? '');
    _balanceController = TextEditingController(text: a != null ? a.balance.toString() : '');
    _numberMaskedController = TextEditingController(text: a?.accountNumberMasked ?? '');
    _selectedType = a?.type ?? AccountType.bank;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _numberMaskedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    Text(
                      widget.existingAccount == null ? 'Add Account' : 'Edit Account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name (e.g. Chase Checking)',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter account name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AccountType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  items: const [
                    DropdownMenuItem(value: AccountType.bank, child: Text('Bank Account')),
                    DropdownMenuItem(value: AccountType.savings, child: Text('Savings Account')),
                    DropdownMenuItem(value: AccountType.creditCard, child: Text('Credit Card')),
                    DropdownMenuItem(value: AccountType.cash, child: Text('Cash Wallet')),
                    DropdownMenuItem(value: AccountType.digitalWallet, child: Text('Digital Wallet')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Current Balance (${authProvider.user?.currency ?? 'USD'})',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter balance';
                    if (double.tryParse(val) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numberMaskedController,
                  decoration: const InputDecoration(
                    labelText: 'Masked Number / Identifier (Optional)',
                    prefixIcon: Icon(Icons.numbers),
                    hintText: '•••• 1234',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.existingAccount == null ? 'Save Account' : 'Update Account'),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    IconData icon;
    Color color;

    switch (_selectedType) {
      case AccountType.bank:
        icon = Icons.account_balance;
        color = const Color(0xFF0F172A);
        break;
      case AccountType.savings:
        icon = Icons.savings;
        color = AppColors.income;
        break;
      case AccountType.creditCard:
        icon = Icons.credit_card;
        color = const Color(0xFF6366F1);
        break;
      case AccountType.cash:
        icon = Icons.account_balance_wallet;
        color = AppColors.warning;
        break;
      case AccountType.digitalWallet:
        icon = Icons.qr_code_2;
        color = const Color(0xFF0EA5E9);
        break;
    }

    final newAcc = AccountModel(
      id: widget.existingAccount?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: double.parse(_balanceController.text.trim()),
      currency: authProvider.user?.currency ?? 'USD',
      accountNumberMasked: _numberMaskedController.text.trim().isNotEmpty
          ? _numberMaskedController.text.trim()
          : null,
      iconCode: icon.codePoint,
      colorValue: color.value,
      updatedAt: DateTime.now(),
    );

    if (widget.existingAccount == null) {
      financeProvider.addAccount(newAcc);
      ToastNotification.show(context, message: 'Account added');
    } else {
      financeProvider.updateAccount(newAcc);
      ToastNotification.show(context, message: 'Account updated');
    }

    Navigator.pop(context);
  }
}
