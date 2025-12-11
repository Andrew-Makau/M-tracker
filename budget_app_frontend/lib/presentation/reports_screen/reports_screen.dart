import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../transaction_history_screen/widgets/monthly_summary_widget.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/app_bottom_nav.dart';

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
  // Mock data for monthly summary
  final Map<String, dynamic> _monthlySummaryData = {
    'month': 'December 2025',
    'totalIncome': 5000.00,
    'totalExpenses': 1847.32,
    'categoryBreakdown': {
      'Food & Dining': 687.50,
      'Transportation': 425.80,
      'Shopping': 312.45,
      'Entertainment': 234.67,
      'Bills & Utilities': 186.90,
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBaseBackground,
      appBar: BrandAppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text('Reports'),
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
              Navigator.pushNamed(context, '/budget-categories-screen');
              break;
            case 3:
              // current screen
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MonthlySummaryWidget(
                summaryData: _monthlySummaryData,
                onTap: () {
                  // Handle tap
                },
              ),
                SizedBox(height: 2.h),
                // Additional report widgets can be added here
              ],
            ),
          ),
        ),
      );
    }
  }
