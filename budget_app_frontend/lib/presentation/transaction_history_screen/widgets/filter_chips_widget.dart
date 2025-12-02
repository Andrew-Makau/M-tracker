import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String) onFilterRemoved;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    super.key,
    required this.activeFilters,
    required this.onFilterRemoved,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> chips = [];

    // Date range chip
    if (activeFilters.containsKey('startDate') &&
        activeFilters.containsKey('endDate')) {
      final DateTime startDate = activeFilters['startDate'];
      final DateTime endDate = activeFilters['endDate'];
      chips.add(_buildFilterChip(
        'Date: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
        'dateRange',
        context,
      ));
    }

    // Category chip
    if (activeFilters.containsKey('category')) {
      chips.add(_buildFilterChip(
        'Category: ${activeFilters['category']}',
        'category',
        context,
      ));
    }

    // Payment method chip
    if (activeFilters.containsKey('paymentMethod')) {
      chips.add(_buildFilterChip(
        'Payment: ${activeFilters['paymentMethod']}',
        'paymentMethod',
        context,
      ));
    }

    // Amount range chip
    if (activeFilters.containsKey('minAmount') ||
        activeFilters.containsKey('maxAmount')) {
      final double minAmount = activeFilters['minAmount'] ?? 0;
      final double maxAmount = activeFilters['maxAmount'] ?? 10000;
      chips.add(_buildFilterChip(
        'Amount: \$${minAmount.toInt()} - \$${maxAmount.toInt()}',
        'amountRange',
        context,
      ));
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Filters (${chips.length})',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (chips.length > 1)
                TextButton(
                  onPressed: onClearAll,
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: chips,
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String filterKey, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.w, top: 1.h, bottom: 1.h),
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onFilterRemoved(filterKey),
              child: Container(
                margin: EdgeInsets.only(left: 1.w, right: 1.w),
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
