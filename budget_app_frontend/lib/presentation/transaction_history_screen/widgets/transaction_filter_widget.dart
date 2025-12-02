import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersApplied;
  final Map<String, dynamic> currentFilters;

  const TransactionFilterWidget({
    super.key,
    required this.onFiltersApplied,
    required this.currentFilters,
  });

  @override
  State<TransactionFilterWidget> createState() =>
      _TransactionFilterWidgetState();
}

class _TransactionFilterWidgetState extends State<TransactionFilterWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  RangeValues _amountRange = const RangeValues(0, 10000);

  final List<String> _categories = [
    'All Categories',
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Other'
  ];

  final List<String> _paymentMethods = [
    'All Methods',
    'Credit Card',
    'Debit Card',
    'Cash',
    'Bank Transfer',
    'Digital Wallet',
    'Cryptocurrency'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _selectedCategory = _filters['category'] ?? 'All Categories';
    _selectedPaymentMethod = _filters['paymentMethod'] ?? 'All Methods';
    _amountRange = RangeValues(
      (_filters['minAmount'] ?? 0).toDouble(),
      (_filters['maxAmount'] ?? 10000).toDouble(),
    );
    if (_filters['startDate'] != null && _filters['endDate'] != null) {
      _selectedDateRange = DateTimeRange(
        start: _filters['startDate'],
        end: _filters['endDate'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Transactions',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Filter
                  _buildFilterSection(
                    'Date Range',
                    _buildDateRangeSelector(),
                  ),

                  SizedBox(height: 3.h),

                  // Category Filter
                  _buildFilterSection(
                    'Category',
                    _buildCategorySelector(),
                  ),

                  SizedBox(height: 3.h),

                  // Amount Range Filter
                  _buildFilterSection(
                    'Amount Range',
                    _buildAmountRangeSelector(),
                  ),

                  SizedBox(height: 3.h),

                  // Payment Method Filter
                  _buildFilterSection(
                    'Payment Method',
                    _buildPaymentMethodSelector(),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        content,
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightTheme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDateRange != null
                  ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                  : 'Select date range',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildAmountRangeSelector() {
    return Column(
      children: [
        RangeSlider(
          values: _amountRange,
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '\$${_amountRange.start.round()}',
            '\$${_amountRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _amountRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_amountRange.start.round()}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              '\$${_amountRange.end.round()}',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPaymentMethod,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _paymentMethods.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedCategory = 'All Categories';
      _selectedPaymentMethod = 'All Methods';
      _amountRange = const RangeValues(0, 10000);
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedDateRange != null) {
      filters['startDate'] = _selectedDateRange!.start;
      filters['endDate'] = _selectedDateRange!.end;
    }

    if (_selectedCategory != null && _selectedCategory != 'All Categories') {
      filters['category'] = _selectedCategory;
    }

    if (_selectedPaymentMethod != null &&
        _selectedPaymentMethod != 'All Methods') {
      filters['paymentMethod'] = _selectedPaymentMethod;
    }

    if (_amountRange.start > 0 || _amountRange.end < 10000) {
      filters['minAmount'] = _amountRange.start;
      filters['maxAmount'] = _amountRange.end;
    }

    widget.onFiltersApplied(filters);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
