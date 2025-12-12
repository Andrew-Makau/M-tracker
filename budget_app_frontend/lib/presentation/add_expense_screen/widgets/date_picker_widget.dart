import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DatePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;
  final Function(DateTimeRange)? onDateRangeSelected;
  final VoidCallback? onCancel;

  const DatePickerWidget({
    super.key,
    required this.onDateSelected,
    this.selectedDate,
    this.onDateRangeSelected,
    this.onCancel,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;
  late DateTime _initialDate;
  DateTimeRange? _initialRange;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now();
    selectedRange = DateTimeRange(start: selectedDate, end: selectedDate);
    _initialDate = selectedDate;
    _initialRange = selectedRange;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _formatRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
    if (sameDay) {
      return _formatDate(start);
    }
    return '${start.month}/${start.day}/${start.year} - ${end.month}/${end.day}/${end.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.colorScheme.primary,
                  onPrimary: Colors.white,
                  surface: AppTheme.lightTheme.colorScheme.surface,
                  onSurface: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedRange = DateTimeRange(start: picked, end: picked);
      });
    }
  }

  void _selectToday() {
    final today = DateTime.now();
    setState(() {
      selectedDate = today;
      selectedRange = DateTimeRange(start: today, end: today);
    });
  }

  void _selectYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    setState(() {
      selectedDate = yesterday;
      selectedRange = DateTimeRange(start: yesterday, end: yesterday);
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
        selectedDate = picked.start;
      });
    }
  }

  void _cancelSelection() {
    setState(() {
      selectedDate = _initialDate;
      selectedRange = _initialRange;
    });
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildQuickDateButton('Today', _selectToday, DateTime.now()),
            SizedBox(width: 3.w),
            _buildQuickDateButton(
              'Yesterday',
              _selectYesterday,
              DateTime.now().subtract(const Duration(days: 1)),
            ),
            SizedBox(width: 3.w),
            _buildCustomDateButton(),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'calendar_today',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  selectedRange != null
                      ? _formatRange(selectedRange!)
                      : _formatDate(selectedDate),
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        // Actions: Save & Cancel
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _cancelSelection,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (selectedRange != null) {
                    widget.onDateRangeSelected?.call(selectedRange!);
                  }
                  widget.onDateSelected(selectedDate);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedRange != null
                            ? 'Date range saved: ${_formatRange(selectedRange!)}'
                            : 'Date saved: ${_formatDate(selectedDate)}',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: CustomIconWidget(
                  iconName: 'check',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: Text(
                  'Save',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(
      String label, VoidCallback onTap, DateTime date) {
    final isSelected =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day) ==
            DateTime(date.year, date.month, date.day);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.white.withOpacity(0.25),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.9),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateButton() {
    final isCustomDate = !_isToday(selectedDate) && !_isYesterday(selectedDate);

    return Expanded(
      child: GestureDetector(
        onTap: _selectDateRange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isCustomDate
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCustomDate
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.white.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'calendar_month',
                color: isCustomDate
                    ? Colors.white
                    : Colors.white.withOpacity(0.9),
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'Custom',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: isCustomDate
                      ? Colors.white
                      : Colors.white.withOpacity(0.9),
                  fontWeight: isCustomDate ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
