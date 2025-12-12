import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewTransactions;
  final VoidCallback onSetAlerts;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onViewTransactions,
    required this.onSetAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final spent = (category['spent'] as num).toDouble();
    final budget = (category['budget'] as num).toDouble();
    final percentage = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    Color progressColor = _getProgressColor(percentage);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(category['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onViewTransactions(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: Colors.white,
              icon: Icons.list,
              label: 'Transactions',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onSetAlerts(),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.notifications,
              label: 'Alerts',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: Color(category['color'] as int)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: category['icon'] as String,
                          color: Color(category['color'] as int),
                          size: 6.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['name'] as String,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${(percentage * 100).toInt()}% of budget used',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: progressColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${spent.toStringAsFixed(2)}',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: progressColor,
                          ),
                        ),
                        Text(
                          'of \$${budget.toStringAsFixed(2)}',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 1.h,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 1.0) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (percentage >= 0.8) {
      return Colors.orange;
    } else {
      return AppTheme.lightTheme.colorScheme.tertiary;
    }
  }
}
