import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BalanceCardWidget extends StatefulWidget {
  final double totalBalance;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final bool useLiveData;

  const BalanceCardWidget({
    super.key,
    required this.totalBalance,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.useLiveData,
  });

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(204),
                  fontSize: 14.sp,
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleVisibility,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: widget.isBalanceVisible
                        ? 'visibility'
                        : 'visibility_off',
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.isBalanceVisible
                      ? '\$${widget.totalBalance.toStringAsFixed(2)}'
                      : '••••••',
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: widget.useLiveData ? 'trending_up' : 'data',
                color: widget.useLiveData ? AppTheme.successLight : Theme.of(context).colorScheme.onPrimary.withAlpha(230),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  widget.useLiveData ? '+2.5% from last month' : 'Displaying mock data',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withAlpha(230),
                    fontSize: 12.sp,
                  ),
                ),
              ),
              if (!widget.useLiveData) ...[
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary.withAlpha(31),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MOCK',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
