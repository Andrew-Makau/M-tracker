import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BalanceCardWidget extends StatefulWidget {
  final double totalBalance;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final bool useLiveData;
  final String? userName;

  const BalanceCardWidget({
    super.key,
    required this.totalBalance,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.useLiveData,
    this.userName,
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
    final cs = Theme.of(context).colorScheme;
    final tt = AppTheme.lightTheme.textTheme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      'Total Balance',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleVisibility,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomIconWidget(
                    iconName: widget.isBalanceVisible
                        ? 'visibility'
                        : 'visibility_off',
                    color: cs.onSecondaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Inner panel: balance amount
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.isBalanceVisible
                      ? '\$${widget.totalBalance.toStringAsFixed(2)}'
                      : '••••••',
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onSurface,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
            ),
          ),
          SizedBox(height: 1.h),
          // Trend/mock row without container; increase contrast
          Row(
            children: [
              CustomIconWidget(
                iconName: widget.useLiveData ? 'trending_up' : 'data',
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  widget.useLiveData ? '+2.5% from last month' : 'Displaying mock data',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              if (!widget.useLiveData) ...[
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.w),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MOCK',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontSize: 12.sp,
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

  String _greeting() {
    final hour = DateTime.now().hour;
    String salutation;
    if (hour < 12) {
      salutation = 'Good Morning';
    } else if (hour < 17) {
      salutation = 'Good Afternoon';
    } else {
      salutation = 'Good Evening';
    }
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      return '$salutation, ${widget.userName}!';
    }
    return salutation;
  }
}
