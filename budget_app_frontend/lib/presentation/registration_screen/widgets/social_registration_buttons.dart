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
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        SizedBox(height: ultraCompact ? 1.2.h : (compact ? 2.h : 3.h)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              context: context,
              iconName: 'g_translate',
              label: 'Google',
              onTap: () => _handleGoogleSignUp(context),
              showLabel: !ultraCompact,
            ),
            _buildSocialButton(
              context: context,
              iconName: 'apple',
              label: 'Apple',
              onTap: () => _handleAppleSignUp(context),
              showLabel: !ultraCompact,
            ),
            _buildSocialButton(
              context: context,
              iconName: 'facebook',
              label: 'Facebook',
              onTap: () => _handleFacebookSignUp(context),
              showLabel: !ultraCompact,
            ),
          ],
        ),
        SizedBox(height: ultraCompact ? 1.5.h : (compact ? 2.5.h : 4.h)),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'or',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
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
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              size: ultraCompact ? 20 : 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            if (showLabel) ...[
              SizedBox(height: compact ? 0.3.h : 0.5.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
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
