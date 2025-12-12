import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FloatingInputField extends StatefulWidget {
  final String label;
  final String hint;
  final String iconName;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleVisibility;
  final bool isPasswordVisible;

  const FloatingInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.iconName,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.validator,
    this.onToggleVisibility,
    this.isPasswordVisible = false,
  });

  @override
  State<FloatingInputField> createState() => _FloatingInputFieldState();
}

class _FloatingInputFieldState extends State<FloatingInputField>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _validateInput(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: _errorText != null
                    ? AppTheme.lightTheme.colorScheme.error
                    : _isFocused
                        ? const Color(0xFF29A385)
                        : const Color(0xFF29A385).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword && !widget.isPasswordVisible,
              onChanged: _validateInput,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isFocused = true;
                });
              },
              onTapOutside: (event) {
                setState(() {
                  _isFocused = false;
                });
              },
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Icon(
                    widget.iconName == 'email'
                        ? Icons.email_outlined
                        : widget.iconName == 'lock'
                            ? Icons.lock_outline
                            : Icons.person_outline,
                    color: const Color(0xFF29A385),
                    size: 22,
                  ),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onToggleVisibility?.call();
                        },
                        icon: Icon(
                          widget.isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF64748B),
                          size: 22,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                hintStyle: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: EdgeInsets.only(left: 4.w, top: 0.5.h),
              child: Text(
                _errorText!,
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
