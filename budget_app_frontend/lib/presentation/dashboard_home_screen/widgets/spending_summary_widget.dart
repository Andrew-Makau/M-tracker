import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SpendingSummaryWidget extends StatelessWidget {
  final double monthlyBudget;
  final double spentAmount;
  final List<Map<String, dynamic>> categoryBreakdown;

  const SpendingSummaryWidget({
    super.key,
    required this.monthlyBudget,
    required this.spentAmount,
    required this.categoryBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    final double safeMonthly = (monthlyBudget <= 0) ? 1.0 : monthlyBudget;
    final double progressPercentage =
      ((spentAmount <= 0 ? 0.0 : spentAmount) / safeMonthly).clamp(0.0, 1.0);
    final double remainingAmount = monthlyBudget - spentAmount;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budget',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${monthlyBudget.toStringAsFixed(0)}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Circular Progress Indicator
          Center(
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: CircularProgressIndicator(
                      value: progressPercentage,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercentage > 0.8
                              ? AppTheme.errorLight
                              : progressPercentage > 0.6
                                  ? AppTheme.warningLight
                                  : AppTheme.successLight,
                        ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'spent',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${spentAmount.toStringAsFixed(2)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorLight,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${remainingAmount.toStringAsFixed(2)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            'Category Breakdown',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...categoryBreakdown.map((category) {
            final String name = category['name'] as String;
            final double amount = category['amount'] as double;
            final Color color = category['color'] as Color;
            final double percentage = (spentAmount <= 0) ? 0.0 : (amount / spentAmount).clamp(0.0, 1.0);

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            name,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Theme.of(context).dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
