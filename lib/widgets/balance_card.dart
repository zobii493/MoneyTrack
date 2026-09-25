import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'add_edit_transaction_modal.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currency = authProvider.user?.currency ?? 'USD';

    final totalBalance = financeProvider.totalBalance;
    final incomeMonth = financeProvider.totalIncomeMonth;
    final expenseMonth = financeProvider.totalExpenseMonth;
    final accountCount = financeProvider.accounts.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.2),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Background Base Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A), // Deep Slate Navy
                    Color(0xFF064E3B), // Deep Emerald
                    Color(0xFF047857), // Bright Emerald Glow
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Decorative Ambient Lighting Spheres
            Positioned(
              top: -30.h,
              right: -30.w,
              child: Container(
                width: 140.w,
                height: 140.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -40.h,
              left: -20.w,
              child: Container(
                width: 160.w,
                height: 160.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withOpacity(0.12),
                ),
              ),
            ),

            // Main Content Layer
            Padding(
              padding: EdgeInsets.all(22.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Net Worth',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$accountCount Active Accounts',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Growth Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              '+8.4%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Prominent Balance Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CurrencyUtils.format(totalBalance, currencyCode: currency),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Mini Monthly Flow Stats (Income vs Expense)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  color: AppColors.income.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 12.sp),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Monthly In', style: TextStyle(color: Colors.white54, fontSize: 10.sp)),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '+${CurrencyUtils.formatCompact(incomeMonth, currencyCode: currency)}',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 20.h, width: 1, color: Colors.white24),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  color: AppColors.expense.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.arrow_upward_rounded, color: Colors.redAccent, size: 12.sp),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Monthly Out', style: TextStyle(color: Colors.white54, fontSize: 10.sp)),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '-${CurrencyUtils.formatCompact(expenseMonth, currencyCode: currency)}',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Action Buttons (Add Income / Add Expense)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const AddEditTransactionModal(
                                initialType: TransactionType.income,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle, color: AppColors.primary, size: 16.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'Add Income',
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const AddEditTransactionModal(
                                initialType: TransactionType.expense,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            ),
                          ),
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.remove_circle, color: Colors.white, size: 16.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'Add Expense',
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                                ),
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
          ],
        ),
      ),
    );
  }
}
