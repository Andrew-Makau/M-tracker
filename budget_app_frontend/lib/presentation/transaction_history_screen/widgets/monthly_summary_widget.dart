import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MonthlySummaryWidget extends StatelessWidget {
  final Map<String, dynamic> summaryData;
  final VoidCallback? onTap;

  const MonthlySummaryWidget({
    super.key,
    required this.summaryData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double totalIncome =
        (summaryData['totalIncome'] as num?)?.toDouble() ?? 0.0;
    final double totalExpenses =
        (summaryData['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    final double netAmount = totalIncome - totalExpenses;
    final String month = summaryData['month'] as String? ?? 'Current Month';
    final Map<String, double> categoryBreakdown = Map<String, double>.from(
        summaryData['categoryBreakdown'] as Map? ?? {});

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  month,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'trending_up',
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Financial Summary
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Income',
                    totalIncome,
                    Colors.green.shade300,
                    'trending_up',
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildSummaryItem(
                    'Expenses',
                    totalExpenses,
                    Colors.red.shade300,
                    'trending_down',
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Net Amount
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Net Amount',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${netAmount >= 0 ? '+' : ''}\$${netAmount.toStringAsFixed(2)}',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            if (categoryBreakdown.isNotEmpty) ...[
              SizedBox(height: 3.h),

              // Category Breakdown Chart
              Text(
                'Top Categories',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 2.h),

              SizedBox(
                height: 20.h,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildPieChart(categoryBreakdown),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 3,
                      child: _buildCategoryLegend(categoryBreakdown),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, double amount, Color color, String iconName) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryBreakdown) {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.orange.shade300,
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.pink.shade300,
      Colors.green.shade300,
      Colors.teal.shade300,
    ];

    int colorIndex = 0;
    categoryBreakdown.entries.take(6).forEach((entry) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: entry.value,
          title: '',
          radius: 8.w,
        ),
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 4.w,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildCategoryLegend(Map<String, double> categoryBreakdown) {
    final List<Color> colors = [
      Colors.orange.shade300,
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.pink.shade300,
      Colors.green.shade300,
      Colors.teal.shade300,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: categoryBreakdown.entries
          .take(6)
          .toList()
          .asMap()
          .entries
          .map((entry) {
        final int index = entry.key;
        final MapEntry<String, double> categoryEntry = entry.value;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  categoryEntry.key,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${categoryEntry.value.toStringAsFixed(0)}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
