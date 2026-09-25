import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import 'toast_notification.dart';

class AddEditTransactionModal extends StatefulWidget {
  final TransactionModel? existingTransaction;
  final TransactionType initialType;

  const AddEditTransactionModal({
    super.key,
    this.existingTransaction,
    this.initialType = TransactionType.expense,
  });

  @override
  State<AddEditTransactionModal> createState() => _AddEditTransactionModalState();
}

class _AddEditTransactionModalState extends State<AddEditTransactionModal> {
  final _formKey = GlobalKey<FormState>();

  late TransactionType _type;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _paymentMethodController;

  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final txn = widget.existingTransaction;

    _type = txn?.type ?? widget.initialType;
    _titleController = TextEditingController(text: txn?.title ?? '');
    _amountController = TextEditingController(text: txn != null ? txn.amount.toString() : '');
    _notesController = TextEditingController(text: txn?.notes ?? '');
    _paymentMethodController = TextEditingController(text: txn?.paymentMethod ?? 'Card');
    _selectedCategoryId = txn?.categoryId;
    _selectedAccountId = txn?.accountId;
    _selectedToAccountId = txn?.toAccountId;
    _selectedDate = txn?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = financeProvider.categories.where((c) {
      if (_type == TransactionType.income) {
        return c.type.name == 'income';
      }
      return c.type.name == 'expense';
    }).toList();

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    if (_selectedAccountId == null && financeProvider.accounts.isNotEmpty) {
      _selectedAccountId = financeProvider.accounts.first.id;
    }

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
                      widget.existingTransaction == null ? 'Add Transaction' : 'Edit Transaction',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Type selector tab
                Row(
                  children: [
                    Expanded(child: _buildTypeSegment(TransactionType.expense, 'Expense', AppColors.expense)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTypeSegment(TransactionType.income, 'Income', AppColors.income)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTypeSegment(TransactionType.transfer, 'Transfer', AppColors.info)),
                  ],
                ),
                const SizedBox(height: 20),
                // Amount Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Amount (${authProvider.user?.currency ?? 'USD'})',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter amount';
                    if (double.tryParse(val) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Title / Merchant Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Merchant / Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter title';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Category Dropdown
                if (_type != TransactionType.transfer) ...[
                  DropdownButtonFormField<String>(
                    value: categories.any((c) => c.id == _selectedCategoryId)
                        ? _selectedCategoryId
                        : (categories.isNotEmpty ? categories.first.id : null),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                                color: Color(cat.colorValue), size: 18),
                            const SizedBox(width: 10),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  ),
                  const SizedBox(height: 16),
                ],
                // Account Dropdown
                DropdownButtonFormField<String>(
                  value: financeProvider.accounts.any((a) => a.id == _selectedAccountId)
                      ? _selectedAccountId
                      : (financeProvider.accounts.isNotEmpty ? financeProvider.accounts.first.id : null),
                  decoration: InputDecoration(
                    labelText: _type == TransactionType.transfer ? 'From Account' : 'Account',
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: financeProvider.accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text('${acc.name} (${acc.currency})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAccountId = val),
                ),
                if (_type == TransactionType.transfer) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: financeProvider.accounts.any((a) => a.id == _selectedToAccountId)
                        ? _selectedToAccountId
                        : (financeProvider.accounts.length > 1 ? financeProvider.accounts[1].id : null),
                    decoration: const InputDecoration(
                      labelText: 'To Account',
                      prefixIcon: Icon(Icons.arrow_forward_rounded),
                    ),
                    items: financeProvider.accounts.map((acc) {
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Text('${acc.name} (${acc.currency})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedToAccountId = val),
                  ),
                ],
                const SizedBox(height: 16),
                // Payment Method & Date Picker Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _paymentMethodController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          prefixIcon: Icon(Icons.payment),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Notes Field
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.existingTransaction == null ? 'Save Transaction' : 'Update Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSegment(TransactionType type, String label, Color activeColor) {
    final isSelected = _type == type;
    return InkWell(
      onTap: () => setState(() => _type = type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : activeColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : activeColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final amount = double.parse(_amountController.text.trim());
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final paymentMethod = _paymentMethodController.text.trim();

    final now = DateTime.now();
    final newTxn = TransactionModel(
      id: widget.existingTransaction?.id ?? const Uuid().v4(),
      userId: authProvider.user?.id ?? 'user_1',
      type: _type,
      amount: amount,
      currency: authProvider.user?.currency ?? 'USD',
      categoryId: _selectedCategoryId ?? 'cat_other_exp',
      accountId: _selectedAccountId ?? 'acc_checking',
      toAccountId: _type == TransactionType.transfer ? _selectedToAccountId : null,
      title: title,
      description: notes,
      date: _selectedDate,
      paymentMethod: paymentMethod,
      notes: notes.isNotEmpty ? notes : null,
      createdAt: widget.existingTransaction?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.existingTransaction == null) {
      financeProvider.addTransaction(newTxn);
      ToastNotification.show(context, message: 'Transaction added successfully');
    } else {
      financeProvider.updateTransaction(newTxn);
      ToastNotification.show(context, message: 'Transaction updated successfully');
    }

    Navigator.pop(context);
  }
}
