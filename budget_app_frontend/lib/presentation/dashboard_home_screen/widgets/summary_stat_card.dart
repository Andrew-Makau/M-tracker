import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String changeText;
  final Color changeColor;
  final List<Color> gradient;
  final IconData icon;
  final Color iconBg;
  final Color titleColor;
  final Color valueColor;
  final Color? borderColor;
  final bool subtleShadow;

  const SummaryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.changeText,
    required this.changeColor,
    required this.gradient,
    required this.icon,
    required this.iconBg,
    required this.titleColor,
    required this.valueColor,
    this.borderColor,
    this.subtleShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool useBorder = gradient.length == 1 && borderColor != null;
    return Container(
      constraints: const BoxConstraints(minHeight: 115),
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 2.5.w),
      decoration: BoxDecoration(
        gradient: gradient.length > 1 ? LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: gradient.length == 1 ? gradient.first : null,
        borderRadius: BorderRadius.circular(16),
        border: useBorder ? Border.all(color: borderColor!.withOpacity(0.4)) : null,
        boxShadow: subtleShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.6.w),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15.sp, color: titleColor.withOpacity(0.9)),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20.sp,
                ),
          ),
          Text(
            changeText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                ),
          ),
        ],
      ),
    );
  }
}
