import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateCategory;

  const EmptyStateWidget({
    super.key,
    required this.onCreateCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'category',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 20.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'No Categories Yet',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Create your first budget category to start tracking your spending and managing your finances effectively.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onCreateCategory,
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text(
                'Create Your First Category',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
