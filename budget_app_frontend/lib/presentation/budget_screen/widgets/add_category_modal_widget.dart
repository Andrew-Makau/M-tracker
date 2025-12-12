import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddCategoryModalWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onCategoryAdded;

  const AddCategoryModalWidget({
    super.key,
    required this.onCategoryAdded,
  });

  @override
  State<AddCategoryModalWidget> createState() => _AddCategoryModalWidgetState();
}

class _AddCategoryModalWidgetState extends State<AddCategoryModalWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String _selectedIcon = 'shopping_cart';
  int _selectedColor = 0xFF3B82F6;

  final List<String> _categoryIcons = [
    'shopping_cart',
    'restaurant',
    'local_gas_station',
    'home',
    'directions_car',
    'medical_services',
    'school',
    'sports_esports',
    'movie',
    'fitness_center',
    'pets',
    'flight',
    'shopping_bag',
    'phone',
    'electric_bolt',
  ];

  final List<int> _categoryColors = [
    0xFF3B82F6, // Blue
    0xFF10B981, // Green
    0xFFF59E0B, // Yellow
    0xFFEF4444, // Red
    0xFF8B5CF6, // Purple
    0xFFF97316, // Orange
    0xFF06B6D4, // Cyan
    0xFFEC4899, // Pink
    0xFF84CC16, // Lime
    0xFF6366F1, // Indigo
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add New Category',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Budget Amount',
              hintText: 'Enter budget amount',
              prefixText: '\$ ',
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Choose Icon',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 15.h,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _categoryIcons.length,
              itemBuilder: (context, index) {
                final icon = _categoryIcons[index];
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: icon,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Choose Color',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 8.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categoryColors.length,
              itemBuilder: (context, index) {
                final color = _categoryColors[index];
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    margin: EdgeInsets.only(right: 2.w),
                    decoration: BoxDecoration(
                      color: Color(color),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Center(
                            child: CustomIconWidget(
                              iconName: 'check',
                              color: Colors.white,
                              size: 5.w,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addCategory,
                  child: Text('Add Category'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  void _addCategory() {
    if (_nameController.text.trim().isEmpty ||
        _budgetController.text.trim().isEmpty) {
      return;
    }

    final category = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'icon': _selectedIcon,
      'color': _selectedColor,
      'budget': double.tryParse(_budgetController.text) ?? 0.0,
      'spent': 0.0,
      'isCustom': true,
    };

    widget.onCategoryAdded(category);
    Navigator.pop(context);
  }
}