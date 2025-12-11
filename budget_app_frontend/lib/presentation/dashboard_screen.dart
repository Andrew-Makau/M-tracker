import 'package:flutter/material.dart';

// Dashboard redesigned to match the provided reference screenshot.

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const totalIncome = 6050.0;
    const totalExpenses = 1590.0;
    const balance = totalIncome - totalExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top brand bar
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF29A385),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.dashboard, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'BudgetFlow',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: Colors.black54)),
                  ],
                ),

                const SizedBox(height: 20),

                // Greeting row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back, Alex', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('December 2024', style: TextStyle(color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF29A385),
                      ),
                      alignment: Alignment.center,
                      child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stat cards grid - centered with creative whitespace
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 900;
                        final isMedium = constraints.maxWidth >= 600;
                        final itemWidth =
                            isWide ? (constraints.maxWidth - 24 * 3) / 4 : isMedium ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                        SizedBox(
                          width: itemWidth,
                          child: StatCard(
                            title: 'Current Balance',
                            value: '\$${balance.toStringAsFixed(0)}',
                            trendLabel: '+12.5% from last month',
                            icon: Icons.account_balance_wallet_outlined,
                            isPositive: true,
                            variant: StatVariant.primary,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: StatCard(
                            title: 'Total Income',
                            value: '\$${totalIncome.toStringAsFixed(0)}',
                            trendLabel: '+8.2% from last month',
                            icon: Icons.trending_up,
                            isPositive: true,
                            variant: StatVariant.income,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: StatCard(
                            title: 'Total Expenses',
                            value: '\$${totalExpenses.toStringAsFixed(0)}',
                            trendLabel: '3.1% from last month',
                            icon: Icons.trending_down,
                            isPositive: false,
                            variant: StatVariant.expense,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: StatCard(
                            title: 'Savings Goal',
                            value: '68%',
                            trendLabel: '+5.4% from last month',
                            icon: Icons.savings_outlined,
                            isPositive: true,
                            variant: StatVariant.defaultVariant,
                          ),
                        ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Supporting UI pieces ----------

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String trendLabel;
  final bool isPositive;
  final StatVariant variant;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.trendLabel, this.isPositive = true, this.variant = StatVariant.primary});

  @override
  Widget build(BuildContext context) {
    final _CardStyle style = _CardStyle.fromVariant(variant, isPositive);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: style.gradient,
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: style.textPrimary)),
                const SizedBox(height: 10),
                Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: style.textPrimary)),
                const SizedBox(height: 6),
                Text(trendLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: style.trendColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: style.iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: style.iconColor, size: 22),
          ),
        ],
      ),
    );
  }
}

class _CardStyle {
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textPrimary;
  final Color trendColor;
  final Color iconBg;
  final Color iconColor;

  const _CardStyle({this.gradient, this.backgroundColor, required this.textPrimary, required this.trendColor, required this.iconBg, required this.iconColor});

  factory _CardStyle.fromVariant(StatVariant variant, bool isPositive) {
    switch (variant) {
      case StatVariant.primary:
        return _CardStyle(
          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF0EA5E9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          textPrimary: Colors.white,
          trendColor: Colors.white,
          iconBg: Colors.white.withOpacity(0.2),
          iconColor: Colors.white,
        );
      case StatVariant.income:
        return const _CardStyle(
          backgroundColor: Color(0xFFE8F8EE),
          textPrimary: Color(0xFF0F5132),
          trendColor: Color(0xFF16A34A),
          iconBg: Color(0xFFD1F1DB),
          iconColor: Color(0xFF15803D),
        );
      case StatVariant.expense:
        return const _CardStyle(
          backgroundColor: Color(0xFFFDECEE),
          textPrimary: Color(0xFF7F1D1D),
          trendColor: Color(0xFFE11D48),
          iconBg: Color(0xFFFAD1D9),
          iconColor: Color(0xFFBE123C),
        );
      case StatVariant.defaultVariant:
        return const _CardStyle(
          backgroundColor: Colors.white,
          textPrimary: Colors.black87,
          trendColor: Color(0xFF16A34A),
          iconBg: Color(0xFFE9EEF7),
          iconColor: Colors.black54,
        );
    }
  }
}

enum StatVariant { primary, income, expense, defaultVariant }
