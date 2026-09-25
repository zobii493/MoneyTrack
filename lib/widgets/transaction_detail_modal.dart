import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'add_edit_transaction_modal.dart';
import 'toast_notification.dart';

class TransactionDetailModal extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final category = financeProvider.getCategoryById(transaction.categoryId);
    final account = financeProvider.getAccountById(transaction.accountId);
    final toAccount = transaction.toAccountId != null
        ? financeProvider.getAccountById(transaction.toAccountId!)
        : null;

    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;

    final iconData = category != null ? IconData(category.iconCode, fontFamily: 'MaterialIcons') : Icons.attach_money;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.all(20.r),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Transaction Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 18.sp,
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
              SizedBox(height: 12.h),

              // Transaction Icon & Amount Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: (isIncome ? AppColors.income : (isTransfer ? AppColors.info : AppColors.expense)).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: isIncome ? AppColors.income : (isTransfer ? AppColors.info : AppColors.expense),
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      transaction.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${isIncome ? '+' : (isTransfer ? '→ ' : '-')}${CurrencyUtils.format(transaction.amount, currencyCode: currency)}',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? AppColors.income : (isTransfer ? AppColors.info : AppColors.expense),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              const Divider(),
              SizedBox(height: 8.h),

              // Detail Rows
              _detailRow(context, 'Category', category?.name ?? 'General'),
              _detailRow(
                context,
                'Account',
                isTransfer && toAccount != null
                    ? '${account?.name ?? 'Account'} → ${toAccount.name}'
                    : (account?.name ?? 'Account'),
              ),
              _detailRow(context, 'Payment Method', transaction.paymentMethod),
              _detailRow(context, 'Date & Time', DateUtilsHelper.formatTransactionDate(transaction.date)),
              if (transaction.notes != null && transaction.notes!.isNotEmpty)
                _detailRow(context, 'Notes', transaction.notes!),

              SizedBox(height: 24.h),

              // Action Buttons Row (Duplicate, Edit, Delete)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final duplicate = transaction.copyWith(
                          id: const Uuid().v4(),
                          title: '${transaction.title} (Copy)',
                          date: DateTime.now(),
                        );
                        financeProvider.addTransaction(duplicate);
                        Navigator.pop(context);
                        ToastNotification.show(context, message: 'Transaction duplicated');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                      ),
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text('Duplicate', style: TextStyle(fontSize: 13.sp)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AddEditTransactionModal(
                            existingTransaction: transaction,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                      ),
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text('Edit', style: TextStyle(fontSize: 13.sp)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmDelete(context, financeProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                      ),
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text('Delete', style: TextStyle(fontSize: 13.sp)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FinanceProvider provider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTransaction(transaction.id);
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
              ToastNotification.show(context, message: 'Transaction deleted', type: ToastType.error);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
