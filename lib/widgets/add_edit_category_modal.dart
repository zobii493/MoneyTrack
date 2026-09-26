import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import 'toast_notification.dart';

class AddEditCategoryModal extends StatefulWidget {
  final CategoryModel? existingCategory;

  const AddEditCategoryModal({super.key, this.existingCategory});

  @override
  State<AddEditCategoryModal> createState() => _AddEditCategoryModalState();
}

class _AddEditCategoryModalState extends State<AddEditCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  CategoryType _type = CategoryType.expense;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.receipt_long,
    Icons.movie,
    Icons.medical_services,
    Icons.school,
    Icons.flight,
    Icons.subscriptions,
    Icons.fitness_center,
    Icons.pets,
    Icons.card_giftcard,
    Icons.payments,
    Icons.laptop_mac,
    Icons.trending_up,
  ];

  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCategory;
    _nameController = TextEditingController(text: c?.name ?? '');
    _type = c?.type ?? CategoryType.expense;
    _selectedIcon = c != null ? IconData(c.iconCode, fontFamily: 'MaterialIcons') : Icons.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.all(24.r),
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
                    Expanded(
                      child: Text(
                        widget.existingCategory == null ? 'New Category' : 'Edit Category',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text('Expense', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold))),
                        selected: _type == CategoryType.expense,
                        selectedColor: AppColors.expense,
                        labelStyle: TextStyle(color: _type == CategoryType.expense ? Colors.white : null),
                        onSelected: (val) => setState(() => _type = CategoryType.expense),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text('Income', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold))),
                        selected: _type == CategoryType.income,
                        selectedColor: AppColors.income,
                        labelStyle: TextStyle(color: _type == CategoryType.income ? Colors.white : null),
                        onSelected: (val) => setState(() => _type = CategoryType.income),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    prefixIcon: Icon(Icons.label_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter name';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                Text('Select Icon', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp)),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: _availableIcons.map((icon) {
                    final isSelected = _selectedIcon.codePoint == icon.codePoint;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      widget.existingCategory == null ? 'Save Category' : 'Update Category',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
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

    final cat = CategoryModel(
      id: widget.existingCategory?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _type,
      iconCode: _selectedIcon.codePoint,
      colorValue: _type == CategoryType.income ? AppColors.income.value : AppColors.primary.value,
      isDefault: false,
    );

    if (widget.existingCategory == null) {
      financeProvider.addCategory(cat);
      ToastNotification.show(context, message: 'Category added');
    } else {
      financeProvider.updateCategory(cat);
      ToastNotification.show(context, message: 'Category updated');
    }

    Navigator.pop(context);
  }
}
