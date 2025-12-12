import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

// Palette constants
const Color kBaseBackground = Color(0xFFF9FAFB);
const Color kBorder = Color(0xFFE0E5EB);
const Color kMutedText = Color(0xFF676F7E);

class IncomeDetailsScreen extends StatefulWidget {
  const IncomeDetailsScreen({super.key});

  @override
  State<IncomeDetailsScreen> createState() => _IncomeDetailsScreenState();
}

class _IncomeDetailsScreenState extends State<IncomeDetailsScreen> {
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
        title: const Text('Income & Expenses'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main income/expense stat
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income & Expenses',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Want to see where your money goes?',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: kMutedText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '6 DEC - 12 DEC',
                                style: AppTheme
                                    .lightTheme.textTheme.labelSmall,
                              ),
                              Text(
                                'VS PREVIOUS PERIOD',
                                style: AppTheme
                                    .lightTheme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ksh 3152.68',
                                style: AppTheme.lightTheme.textTheme
                                    .headlineSmall,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '0%',
                                  style: AppTheme.lightTheme.textTheme
                                      .labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
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
              SizedBox(height: 2.h),
              // Income section
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INCOME',
                      style: AppTheme.lightTheme.textTheme.labelSmall
                          ?.copyWith(
                        color: kMutedText,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0.00',
                          style: AppTheme.lightTheme.textTheme.bodyLarge,
                        ),
                        Text(
                          '- -',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              // Income items
              _buildIncomeItem('Income', '0.00'),
              SizedBox(height: 2.h),
              // Expenses section
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPENSES',
                      style: AppTheme.lightTheme.textTheme.labelSmall
                          ?.copyWith(
                        color: kMutedText,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0.00',
                          style: AppTheme.lightTheme.textTheme.bodyLarge,
                        ),
                        Text(
                          '- -',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              // Expense items
              _buildExpenseItem('Food & Drinks', '0.00', Colors.red),
              _buildExpenseItem('Shopping', '0.00', Colors.blue),
              _buildExpenseItem('Housing', '0.00', Colors.orange),
              _buildExpenseItem('Transportation', '0.00', Colors.cyan),
              _buildExpenseItem('Vehicle', '0.00', Colors.purple),
              _buildExpenseItem('Life & Entertainment', '0.00', Colors.green),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  // Income item widget
  Widget _buildIncomeItem(String name, String amount) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3.w),
              Text(name, style: AppTheme.lightTheme.textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              Text(amount, style: AppTheme.lightTheme.textTheme.bodyMedium),
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right, size: 5.w),
            ],
          ),
        ],
      ),
    );
  }

  // Expense item widget
  Widget _buildExpenseItem(String name, String amount, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3.w),
              Text(name, style: AppTheme.lightTheme.textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              Text(amount, style: AppTheme.lightTheme.textTheme.bodyMedium),
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right, size: 5.w),
            ],
          ),
        ],
      ),
    );
  }
}
