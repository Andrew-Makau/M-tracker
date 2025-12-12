import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialRegistrationButtons extends StatelessWidget {
  const SocialRegistrationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
  final bool compact = size.height < 740; // tighten spacing on smaller heights
  final bool ultraCompact = size.height < 650; // most aggressive compacting

    return Column(
      children: [
        if (!ultraCompact)
          Text(
            'Sign up with',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF475569),
              fontSize: 16.sp,
            ),
          ),
        SizedBox(height: ultraCompact ? 1.2.h : (compact ? 2.h : 3.h)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              context: context,
              iconName: 'google',
              label: 'Google',
              onTap: () => _handleGoogleSignUp(context),
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              showLabel: !ultraCompact,
            ),
            _buildSocialButton(
              context: context,
              iconName: 'apple',
              label: 'Apple',
              onTap: () => _handleAppleSignUp(context),
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              showLabel: !ultraCompact,
            ),
            _buildSocialButton(
              context: context,
              iconName: 'facebook',
              label: 'Facebook',
              onTap: () => _handleFacebookSignUp(context),
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              showLabel: !ultraCompact,
            ),
          ],
        ),
        SizedBox(height: ultraCompact ? 1.5.h : (compact ? 2.5.h : 4.h)),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: const Color(0xFFE0E5EB),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'or',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                  fontSize: 16.sp,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: const Color(0xFFE0E5EB),
                thickness: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String iconName,
    required String label,
    required VoidCallback onTap,
    bool showLabel = true,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final size = MediaQuery.of(context).size;
    final bool compact = size.height < 740;
    final bool ultraCompact = size.height < 650;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25.w,
        height: ultraCompact ? 4.4.h : (compact ? 5.h : 6.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E5EB),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              size: ultraCompact ? 20 : 24,
              color: textColor ?? Colors.black87,
            ),
            if (showLabel) ...[
              SizedBox(height: compact ? 0.3.h : 0.5.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: textColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleGoogleSignUp(BuildContext context) {
    // Simulate Google sign up process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google sign up initiated'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _handleAppleSignUp(BuildContext context) {
    // Simulate Apple sign up process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Apple sign up initiated'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _handleFacebookSignUp(BuildContext context) {
    // Simulate Facebook sign up process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Facebook sign up initiated'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }
}
