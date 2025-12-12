import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../widgets/app_bottom_nav.dart';
import 'screens/balance_details_screen.dart';
import 'screens/spending_details_screen.dart';
import 'screens/income_details_screen.dart';

// Palette constants (matching dashboard design system)
const Color kPrimary = Color(0xFF29A385);
const Color kPrimaryText = Color(0xFFFFFFFF);
const Color kSecondary = Color(0xFFEDF0F3);
const Color kSecondaryText = Color(0xFF303A50);
const Color kAccent = Color(0xFFECF9F5);
const Color kAccentText = Color(0xFF1F7A63);
const Color kBaseBackground = Color(0xFFF9FAFB);
const Color kBaseText = Color(0xFF131720);
const Color kCard = Color(0xFFFFFFFF);
const Color kCardText = Color(0xFF131720);
const Color kMuted = Color(0xFFE8EBEE);
const Color kMutedText = Color(0xFF676F7E);
const Color kDestructive = Color(0xFFDC2828);
const Color kDestructiveText = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFE0E5EB);
const Color kInput = Color(0xFFE0E5EB);
const Color kFocusRing = Color(0xFF29A385);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Statistics data for glass morphism cards
  final List<Map<String, dynamic>> _statisticsCards = [
    {
      'label': 'BALANCE',
      'value': 'Ksh 3152.68',
      'icon': 'trending_up',
      'type': 'balance',
    },
    {
      'label': 'SPENDING',
      'value': 'Ksh 1847.32',
      'icon': 'donut_large',
      'type': 'spending',
    },
    {
      'label': 'REPORTS - INCOME',
      'value': 'Ksh 5000.00',
      'icon': 'savings',
      'type': 'income',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBaseBackground,
      appBar: BrandAppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Reports',
          style: TextStyle(
            color: kBaseText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboardHome,
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamed(context, '/transaction-history-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/budget-screen');
              break;
            case 3:
              // current screen
              break;
            case 4:
              Navigator.pushNamed(context, '/goals-screen');
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: kBaseText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                // Glass morphism stat cards
                ..._statisticsCards.map((card) => _buildGlassMorphismCard(
                  label: card['label'],
                  value: card['value'],
                  icon: card['icon'],
                  type: card['type'],
                )),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Glass morphism stat card widget with hover effect
  Widget _buildGlassMorphismCard({
    required String label,
    required String value,
    required String icon,
    required String type,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: GestureDetector(
        onTap: () => _handleCardTap(type),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(4.w),
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
                                label,
                                style: AppTheme.lightTheme.textTheme
                                    .labelMedium
                                    ?.copyWith(
                                  color: kMutedText,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                value,
                                style: AppTheme.lightTheme.textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  color: kBaseText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: icon,
                            color: kPrimary,
                            size: 6.w,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handle card tap to show detailed view
  void _handleCardTap(String type) {
    if (type == 'balance') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BalanceDetailsScreen(),
        ),
      );
    } else if (type == 'spending') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SpendingDetailsScreen(),
        ),
      );
    } else if (type == 'income') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IncomeDetailsScreen(),
        ),
      );
    }
  }
}
