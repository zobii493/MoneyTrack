import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import 'toast_notification.dart';

class AddEditBudgetModal extends StatefulWidget {
  final BudgetModel? existingBudget;

  const AddEditBudgetModal({super.key, this.existingBudget});

  @override
  State<AddEditBudgetModal> createState() => _AddEditBudgetModalState();
}

class _AddEditBudgetModalState extends State<AddEditBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String? _selectedCategoryId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBudget;
    _amountController = TextEditingController(text: b != null ? b.amountLimit.toString() : '');
    _selectedCategoryId = b?.categoryId;
    _selectedPeriod = b?.period ?? BudgetPeriod.monthly;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expenseCategories = financeProvider.categories.where((c) => c.type.name == 'expense').toList();

    if (_selectedCategoryId == null && expenseCategories.isNotEmpty) {
      _selectedCategoryId = expenseCategories.first.id;
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
                      widget.existingBudget == null ? 'Set Budget' : 'Edit Budget',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: expenseCategories.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : (expenseCategories.isNotEmpty ? expenseCategories.first.id : null),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: expenseCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monthly Limit (${authProvider.user?.currency ?? 'USD'})',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter budget limit';
                    if (double.tryParse(val) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BudgetPeriod>(
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  items: const [
                    DropdownMenuItem(value: BudgetPeriod.monthly, child: Text('Monthly')),
                    DropdownMenuItem(value: BudgetPeriod.weekly, child: Text('Weekly')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPeriod = val);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.existingBudget == null ? 'Save Budget' : 'Update Budget'),
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
    final limit = double.parse(_amountController.text.trim());

    final newBudget = BudgetModel(
      id: widget.existingBudget?.id ?? const Uuid().v4(),
      categoryId: _selectedCategoryId ?? 'cat_food',
      amountLimit: limit,
      period: _selectedPeriod,
      startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    );

    if (widget.existingBudget == null) {
      financeProvider.addBudget(newBudget);
      ToastNotification.show(context, message: 'Budget created');
    } else {
      financeProvider.updateBudget(newBudget);
      ToastNotification.show(context, message: 'Budget updated');
    }

    Navigator.pop(context);
  }
}
