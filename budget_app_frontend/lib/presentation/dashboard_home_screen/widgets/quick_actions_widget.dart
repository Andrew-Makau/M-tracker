import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onViewBudgets;
  final VoidCallback onViewReports;

  const QuickActionsWidget({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onViewBudgets,
    required this.onViewReports,
  });

  @override
  Widget build(BuildContext context) {
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
      child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: 'remove',
                  label: 'Add Expense',
                  color: AppTheme.errorLight,
                  onTap: onAddExpense,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: 'add',
                  label: 'Add Income',
                  color: AppTheme.successLight,
                  onTap: onAddIncome,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: 'pie_chart',
                  label: 'Budgets',
                  color: AppTheme.categoryColors[2],
                  onTap: onViewBudgets,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: 'bar_chart',
                  label: 'Reports',
                  color: AppTheme.categoryColors[5],
                  onTap: onViewReports,
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
