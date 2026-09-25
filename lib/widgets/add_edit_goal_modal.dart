import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import 'toast_notification.dart';

class AddEditGoalModal extends StatefulWidget {
  final GoalModel? existingGoal;

  const AddEditGoalModal({super.key, this.existingGoal});

  @override
  State<AddEditGoalModal> createState() => _AddEditGoalModalState();
}

class _AddEditGoalModalState extends State<AddEditGoalModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _notesController;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;
    _titleController = TextEditingController(text: g?.title ?? '');
    _targetAmountController = TextEditingController(text: g != null ? g.targetAmount.toString() : '');
    _currentAmountController = TextEditingController(text: g != null ? g.currentAmount.toString() : '0');
    _notesController = TextEditingController(text: g?.notes ?? '');
    _targetDate = g?.targetDate ?? DateTime.now().add(const Duration(days: 180));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _notesController.dispose();
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
                      widget.existingGoal == null ? 'Create Goal' : 'Edit Goal',
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
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title (e.g. Emergency Fund)',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter goal title';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Target (${authProvider.user?.currency ?? 'USD'})',
                          prefixIcon: const Icon(Icons.track_changes),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter target';
                          if (double.tryParse(val) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _currentAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Current Saved',
                          prefixIcon: const Icon(Icons.savings),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter amount';
                          if (double.tryParse(val) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setState(() => _targetDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Target Completion Date',
                      prefixIcon: Icon(Icons.event),
                    ),
                    child: Text(
                      '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.existingGoal == null ? 'Create Goal' : 'Update Goal'),
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

    final newGoal = GoalModel(
      id: widget.existingGoal?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text.trim()),
      currentAmount: double.parse(_currentAmountController.text.trim()),
      currency: authProvider.user?.currency ?? 'USD',
      targetDate: _targetDate,
      iconCode: Icons.savings.codePoint,
      colorValue: AppColors.primary.value,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
    );

    if (widget.existingGoal == null) {
      financeProvider.addGoal(newGoal);
      ToastNotification.show(context, message: 'Goal created successfully');
    } else {
      financeProvider.updateGoal(newGoal);
      ToastNotification.show(context, message: 'Goal updated successfully');
    }

    Navigator.pop(context);
  }
}
