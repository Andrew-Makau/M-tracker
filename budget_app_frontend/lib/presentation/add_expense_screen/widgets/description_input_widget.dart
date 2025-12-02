import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DescriptionInputWidget extends StatefulWidget {
  final Function(String) onDescriptionChanged;
  final String? initialDescription;

  const DescriptionInputWidget({
    super.key,
    required this.onDescriptionChanged,
    this.initialDescription,
  });

  @override
  State<DescriptionInputWidget> createState() => _DescriptionInputWidgetState();
}

class _DescriptionInputWidgetState extends State<DescriptionInputWidget> {
  late TextEditingController _descriptionController;
  final FocusNode _focusNode = FocusNode();

  final List<String> suggestions = [
    'Lunch at restaurant',
    'Coffee with friends',
    'Grocery shopping',
    'Gas for car',
    'Movie tickets',
    'Online shopping',
    'Uber ride',
    'Pharmacy',
    'Gym membership',
    'Phone bill',
  ];

  List<String> filteredSuggestions = [];
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _descriptionController.addListener(_onDescriptionChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onDescriptionChanged() {
    final text = _descriptionController.text;
    widget.onDescriptionChanged(text);

    if (text.isNotEmpty) {
      setState(() {
        filteredSuggestions = suggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(text.toLowerCase()))
            .take(3)
            .toList();
        showSuggestions = filteredSuggestions.isNotEmpty && _focusNode.hasFocus;
      });
    } else {
      setState(() {
        showSuggestions = false;
        filteredSuggestions = [];
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        showSuggestions = false;
      });
    } else if (_descriptionController.text.isNotEmpty &&
        filteredSuggestions.isNotEmpty) {
      setState(() {
        showSuggestions = true;
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    _descriptionController.text = suggestion;
    widget.onDescriptionChanged(suggestion);
    setState(() {
      showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        TextField(
          controller: _descriptionController,
          focusNode: _focusNode,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'What did you spend on?',
            hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.6),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.lightTheme.colorScheme.surface,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
        ),
        if (showSuggestions) ...[
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: filteredSuggestions.map((suggestion) {
                return InkWell(
                  onTap: () => _selectSuggestion(suggestion),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lightbulb_outline',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'arrow_forward_ios',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 3.w,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
