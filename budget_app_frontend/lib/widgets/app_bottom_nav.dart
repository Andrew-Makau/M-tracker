import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

// Palette constants
const Color kPrimary = Color(0xFF29A385);
const Color kBorder = Color(0xFFE0E5EB);

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border(
          top: BorderSide(color: kBorder, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_outlined, 'Home', 0),
              _buildNavItem(context, Icons.receipt_long_outlined, 'Transactions', 1),
              _buildNavItem(context, Icons.account_balance_wallet_outlined, 'Budget', 2),
              _buildNavItem(context, Icons.bar_chart_outlined, 'Reports', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? kPrimary : const Color(0xFF9E9E9E),
              size: 24,
            ),
            SizedBox(height: 0.3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isActive ? kPrimary : const Color(0xFF9E9E9E),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
