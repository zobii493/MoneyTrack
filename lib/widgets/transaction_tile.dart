import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currency = authProvider.user?.currency ?? 'USD';

    final category = financeProvider.getCategoryById(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;

    final iconData = category != null ? IconData(category.iconCode, fontFamily: 'MaterialIcons') : Icons.attach_money;
    final catColor = category != null ? Color(category.colorValue) : AppColors.primary;

    Color amountColor;
    String prefix;

    if (isIncome) {
      amountColor = AppColors.income;
      prefix = '+';
    } else if (isTransfer) {
      amountColor = AppColors.info;
      prefix = '→ ';
    } else {
      amountColor = AppColors.expense;
      prefix = '-';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(iconData, color: catColor, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${category?.name ?? 'General'} • ${DateUtilsHelper.formatTransactionDate(transaction.date)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11.sp,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix${CurrencyUtils.format(transaction.amount, currencyCode: currency)}',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    transaction.paymentMethod,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11.sp,
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
}
