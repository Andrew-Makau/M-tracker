import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/app_bottom_nav.dart';
import '../../core/app_export.dart';

// Palette constants
const Color kBaseBackground = Color(0xFFF9FAFB);
const Color kCard = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFE0E5EB);
const Color kBaseText = Color(0xFF131720);
const Color kPrimary = Color(0xFF29A385);
const Color kMutedText = Color(0xFF676F7E);

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _currentIndex = 4; // Goals index

  // Mock data for goals
  final List<Map<String, dynamic>> _goals = [
    {
      'id': 1,
      'name': 'Emergency Fund',
      'icon': 'savings',
      'color': 0xFF10B981,
      'currentAmount': 6800.0,
      'targetAmount': 10000.0,
      'monthlyContribution': 500.0,
      'dueDate': 'Jan 2025',
    },
    {
      'id': 2,
      'name': 'Vacation to Japan',
      'icon': 'flight',
      'color': 0xFF3B82F6,
      'currentAmount': 2100.0,
      'targetAmount': 5000.0,
      'monthlyContribution': 250.0,
      'dueDate': 'Aug 2025',
    },
    {
      'id': 3,
      'name': 'New Car',
      'icon': 'directions_car',
      'color': 0xFF8B5CF6,
      'currentAmount': 8500.0,
      'targetAmount': 25000.0,
      'monthlyContribution': 300.0,
      'dueDate': 'Dec 2025',
    },
    {
      'id': 4,
      'name': 'House Down Payment',
      'icon': 'home',
      'color': 0xFF0EA5E9,
      'currentAmount': 19000.0,
      'targetAmount': 60000.0,
      'monthlyContribution': 1600.0,
      'dueDate': 'Jan 2026',
    },
    {
      'id': 5,
      'name': 'Education Fund',
      'icon': 'school',
      'color': 0xFFF59E0B,
      'currentAmount': 4200.0,
      'targetAmount': 15000.0,
      'monthlyContribution': 400.0,
      'dueDate': 'Sep 2026',
    },
    {
      'id': 6,
      'name': 'New Laptop',
      'icon': 'laptop_mac',
      'color': 0xFFEC4899,
      'currentAmount': 1800.0,
      'targetAmount': 2500.0,
      'monthlyContribution': 250.0,
      'dueDate': 'Dec 2025',
    },
  ];

  double get _totalSaved =>
      _goals.fold(0, (sum, goal) => sum + goal['currentAmount']);

  double get _totalTarget =>
      _goals.fold(0, (sum, goal) => sum + goal['targetAmount']);

  double get _overallProgress =>
      _totalTarget > 0 ? (_totalSaved / _totalTarget) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBaseBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Savings Goals',
          style: TextStyle(
            color: kBaseText,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: ElevatedButton(
              onPressed: _showNewGoalDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18),
                  SizedBox(width: 1.w),
                  Text(
                    'New Goal',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.flag,
                      iconColor: kPrimary,
                      label: 'Active Goals',
                      value: '${_goals.length}',
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.account_balance_wallet,
                      iconColor: Color(0xFF3B82F6),
                      label: 'Total Saved',
                      value: '\$${_totalSaved.toStringAsFixed(0)}',
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.trending_up,
                      iconColor: Color(0xFF8B5CF6),
                      label: 'Overall Progress',
                      value: '${_overallProgress.toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              // Goal cards
              ..._goals.map((goal) => _buildGoalCard(goal)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: kMutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: kBaseText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    double percentage = goal['targetAmount'] > 0
        ? (goal['currentAmount'] / goal['targetAmount']) * 100
        : 0;
    double remaining = goal['targetAmount'] - goal['currentAmount'];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Color(goal['color']).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(goal['icon']),
                      color: Color(goal['color']),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    goal['name'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: kBaseText,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    goal['dueDate'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: kMutedText,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () => _showEditGoalDialog(goal),
                    child: Icon(
                      Icons.edit,
                      color: kMutedText,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Amount remaining
          Text(
            '\$${remaining.toStringAsFixed(0)} remaining',
            style: TextStyle(
              fontSize: 16.sp,
              color: kMutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Color(0xFFE8EBEE),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(goal['color']),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          // Bottom info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${goal['currentAmount'].toStringAsFixed(0)} / \$${goal['targetAmount'].toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: kBaseText,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Color(goal['color']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(goal['color']),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '\$${goal['monthlyContribution'].toStringAsFixed(0)}/month',
            style: TextStyle(
              fontSize: 16.sp,
              color: kMutedText,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'flight':
        return Icons.flight;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'laptop_mac':
        return Icons.laptop_mac;
      default:
        return Icons.flag;
    }
  }

  void _showEditGoalDialog(Map<String, dynamic> goal) {
    final nameController = TextEditingController(text: goal['name']);
    final targetAmountController = TextEditingController(
      text: goal['targetAmount']?.toStringAsFixed(0) ?? '',
    );
    final currentSavedController = TextEditingController(
      text: goal['currentAmount']?.toStringAsFixed(0) ?? '',
    );
    final deadlineController = TextEditingController(text: goal['dueDate'] ?? '');
    final monthlyContributionController = TextEditingController(
      text: goal['monthlyContribution']?.toStringAsFixed(0) ?? '',
    );
    String? selectedIcon = goal['icon'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Edit Goal'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Icon Selection
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'savings', child: Row(children: [Icon(Icons.savings), SizedBox(width: 8), Text('Savings')])),
                    DropdownMenuItem(value: 'flight', child: Row(children: [Icon(Icons.flight), SizedBox(width: 8), Text('Travel')])),
                    DropdownMenuItem(value: 'directions_car', child: Row(children: [Icon(Icons.directions_car), SizedBox(width: 8), Text('Car')])),
                    DropdownMenuItem(value: 'home', child: Row(children: [Icon(Icons.home), SizedBox(width: 8), Text('Home')])),
                    DropdownMenuItem(value: 'school', child: Row(children: [Icon(Icons.school), SizedBox(width: 8), Text('Education')])),
                    DropdownMenuItem(value: 'laptop_mac', child: Row(children: [Icon(Icons.laptop_mac), SizedBox(width: 8), Text('Electronics')])),
                  ],
                  onChanged: (value) => setState(() => selectedIcon = value),
                ),
              ),
              SizedBox(height: 2.h),
              // Target Amount and Current Saved
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: targetAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Target Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: currentSavedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Current Saved',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Deadline and Monthly Contribution
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deadlineController,
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: monthlyContributionController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Monthly Contribution',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final targetAmount = double.tryParse(targetAmountController.text) ?? 0.0;

              if (name.isEmpty || selectedIcon == null || targetAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Goal "$name" updated successfully'),
                  backgroundColor: kPrimary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
            ),
            child: const Text('Update Goal'),
          ),
        ],
      ),
    );
  }

  void _showNewGoalDialog() {
    final nameController = TextEditingController();
    final targetAmountController = TextEditingController();
    final currentSavedController = TextEditingController();
    final deadlineController = TextEditingController();
    final monthlyContributionController = TextEditingController();
    String? selectedIcon;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('New Goal'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g. Emergency Fund',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Icon Selection
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    hintText: 'Select Icon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'savings', child: Row(children: [Icon(Icons.savings), SizedBox(width: 8), Text('Savings')])),
                    DropdownMenuItem(value: 'flight', child: Row(children: [Icon(Icons.flight), SizedBox(width: 8), Text('Travel')])),
                    DropdownMenuItem(value: 'directions_car', child: Row(children: [Icon(Icons.directions_car), SizedBox(width: 8), Text('Car')])),
                    DropdownMenuItem(value: 'home', child: Row(children: [Icon(Icons.home), SizedBox(width: 8), Text('Home')])),
                    DropdownMenuItem(value: 'school', child: Row(children: [Icon(Icons.school), SizedBox(width: 8), Text('Education')])),
                    DropdownMenuItem(value: 'laptop_mac', child: Row(children: [Icon(Icons.laptop_mac), SizedBox(width: 8), Text('Electronics')])),
                  ],
                  onChanged: (value) => setState(() => selectedIcon = value),
                ),
              ),
              SizedBox(height: 2.h),
              // Target Amount and Current Saved
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: targetAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Target Amount',
                        hintText: '000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: currentSavedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Current Saved',
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Deadline and Monthly Contribution
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deadlineController,
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        hintText: 'e.g. Jun 2025',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: monthlyContributionController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Monthly Contribution',
                        hintText: '000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final targetAmount = double.tryParse(targetAmountController.text) ?? 0.0;

              if (name.isEmpty || selectedIcon == null || targetAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                  ),
                );
                return;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Goal "$name" created with target \$${targetAmount.toStringAsFixed(0)}'),
                  backgroundColor: kPrimary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
            ),
            child: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard-home-screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/transaction-history-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/budget-screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/reports-screen');
        break;
      case 4:
        // Already on goals screen
        break;
    }
  }
}
