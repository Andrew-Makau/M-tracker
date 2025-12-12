import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../transaction_history_screen/widgets/monthly_summary_widget.dart';

// Palette constants
const Color kBaseBackground = Color(0xFFF9FAFB);
const Color kBorder = Color(0xFFE0E5EB);

class BalanceDetailsScreen extends StatefulWidget {
  const BalanceDetailsScreen({super.key});

  @override
  State<BalanceDetailsScreen> createState() => _BalanceDetailsScreenState();
}

class _BalanceDetailsScreenState extends State<BalanceDetailsScreen> {
  late DateTime _selectedDate;

  final Map<String, dynamic> _monthlySummaryData = {
    'month': 'December 2025',
    'totalIncome': 5000.00,
    'totalExpenses': 1847.32,
    'categoryBreakdown': {
      'Food & Dining': 687.50,
      'Transportation': 425.80,
      'Shopping': 312.45,
      'Entertainment': 234.67,
      'Bills & Utilities': 186.90,
    }
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

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
        title: const Text('Balance Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${_selectedDate.toString().split(' ')[0]}',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              // Daily summary card
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day Summary',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Ksh 0.00',
                              style:
                                  AppTheme.lightTheme.textTheme.headlineSmall
                                      ?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Expenses',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Ksh 0.00',
                              style:
                                  AppTheme.lightTheme.textTheme.headlineSmall
                                      ?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              // Monthly summary
              MonthlySummaryWidget(
                summaryData: _monthlySummaryData,
                onTap: () {},
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
