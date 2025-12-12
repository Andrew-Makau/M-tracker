import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_export.dart';

// Palette constants
const Color kBaseBackground = Color(0xFFF9FAFB);
const Color kBorder = Color(0xFFE0E5EB);

class SpendingDetailsScreen extends StatefulWidget {
  const SpendingDetailsScreen({super.key});

  @override
  State<SpendingDetailsScreen> createState() => _SpendingDetailsScreenState();
}

class _SpendingDetailsScreenState extends State<SpendingDetailsScreen> {
  // Daily spending data for charts
  final List<Map<String, dynamic>> _dailyData = [
    {'day': 'Jul', 'income': 4500, 'expenses': 3200},
    {'day': 'Aug', 'income': 4800, 'expenses': 3500},
    {'day': 'Sep', 'income': 4600, 'expenses': 3300},
    {'day': 'Oct', 'income': 5000, 'expenses': 3800},
    {'day': 'Nov', 'income': 5200, 'expenses': 4000},
    {'day': 'Dec', 'income': 5500, 'expenses': 3100},
  ];

  // Expense breakdown data
  final Map<String, dynamic> _expenseBreakdown = {
    'Food & Dining': 25,
    'Transportation': 15,
    'Shopping': 20,
    'Entertainment': 12,
    'Housing': 22,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBaseBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Spending Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income vs Expenses Chart
              Text(
                'Income vs Expenses',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: _buildIncomeVsExpensesChart(),
              ),
              SizedBox(height: 3.h),
              // Expense Breakdown Chart
              Text(
                'Expense Breakdown by Category',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: _buildExpenseBreakdownChart(),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  // Build Income vs Expenses Bar Chart
  Widget _buildIncomeVsExpensesChart() {
    return SizedBox(
      height: 30.h,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 6000,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < _dailyData.length) {
                    return Text(_dailyData[index]['day']);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${(value ~/ 1000)}k');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _dailyData.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: (e.value['income'] as num).toDouble(),
                  color: Colors.green,
                  width: 5.w,
                ),
                BarChartRodData(
                  toY: (e.value['expenses'] as num).toDouble(),
                  color: Colors.red,
                  width: 5.w,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Build Expense Breakdown Pie Chart
  Widget _buildExpenseBreakdownChart() {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFF9B59B6),
    ];

    return SizedBox(
      height: 30.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: _expenseBreakdown.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((e) {
                    return PieChartSectionData(
                      color: colors[e.key % colors.length],
                      value: (e.value.value as num).toDouble(),
                      title: '${e.value.value}%',
                      radius: 10.w,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  })
                  .toList(),
              centerSpaceRadius: 15.w,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Ksh 1847.32',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
