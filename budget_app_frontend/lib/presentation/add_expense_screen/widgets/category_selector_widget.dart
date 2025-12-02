import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategorySelectorWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onCategorySelected;
  final Map<String, dynamic>? selectedCategory;

  const CategorySelectorWidget({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  final List<Map<String, dynamic>> categories = [
    {
      'id': 1,
      'name': 'Food & Dining',
      'icon': 'restaurant',
      'color': const Color(0xFFFF6B6B),
    },
    {
      'id': 2,
      'name': 'Transportation',
      'icon': 'directions_car',
      'color': const Color(0xFF4ECDC4),
    },
    {
      'id': 3,
      'name': 'Shopping',
      'icon': 'shopping_bag',
      'color': const Color(0xFFFFE66D),
    },
    {
      'id': 4,
      'name': 'Entertainment',
      'icon': 'movie',
      'color': const Color(0xFFA8E6CF),
    },
    {
      'id': 5,
      'name': 'Health',
      'icon': 'local_hospital',
      'color': const Color(0xFFFF8B94),
    },
    {
      'id': 6,
      'name': 'Bills & Utilities',
      'icon': 'receipt',
      'color': const Color(0xFFB4A7D6),
    },
    {
      'id': 7,
      'name': 'Travel',
      'icon': 'flight',
      'color': const Color(0xFF88D8B0),
    },
    {
      'id': 8,
      'name': 'Education',
      'icon': 'school',
      'color': const Color(0xFFFFC3A0),
    },
  ];

  Map<String, dynamic>? selectedCategory;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    selectedCategoryId = widget.selectedCategory != null ? widget.selectedCategory!['id'] as int : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        // Dropdown selector with icons
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedCategoryId,
              hint: Row(
                children: [
                  Icon(Icons.category, color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 2.w),
                  Text('Select category', style: AppTheme.lightTheme.textTheme.bodyMedium),
                ],
              ),
              items: categories.map((category) {
                final id = category['id'] as int;
                return DropdownMenuItem<int>(
                  value: id,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.6.w),
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: category['icon'] as String,
                          color: category['color'] as Color,
                          size: 5.w,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCategoryId = val;
                  selectedCategory = categories.firstWhere((c) => c['id'] == val);
                });
                if (selectedCategory != null) {
                  widget.onCategorySelected(selectedCategory!);
                  HapticFeedback.lightImpact();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}