import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none, // allow the active circle to render fully
        children: [
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary, // bar background with rounded corners
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
          ),
          CurvedNavigationBar(
            height: 58,
            backgroundColor: Colors.transparent,
            color: Colors.transparent, // use the container for the bar paint and rounding
            buttonBackgroundColor: const Color(0xFF29A385),
            animationCurve: Curves.easeOutCubic,
            animationDuration: const Duration(milliseconds: 240),
            items: [
              Icon(
                Icons.home,
                size: 30,
                color: currentIndex == 0
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.white70,
              ),
              Icon(
                Icons.history,
                size: 30,
                color: currentIndex == 1
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.white70,
              ),
              Icon(
                Icons.pie_chart,
                size: 30,
                color: currentIndex == 2
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.white70,
              ),
              Icon(
                Icons.bar_chart,
                size: 30,
                color: currentIndex == 3
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.white70,
              ),
            ],
            index: currentIndex,
            onTap: (index) {
              HapticFeedback.lightImpact();
              onTap(index);
            },
          ),
        ],
      ),
    );
  }
}
